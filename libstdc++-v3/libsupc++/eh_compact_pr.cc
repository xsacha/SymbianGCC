#ifdef MD_HAVE_COMPACT_EH
// -*- C++ -*- The GNU C++ compact exception personality routine
// Copyright (C) 2012
// 
// Free Software Foundation, Inc.
//
// This file is part of GCC.
//
// GCC is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// GCC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// Under Section 7 of GPL version 3, you are granted additional
// permissions described in the GCC Runtime Library Exception, version
// 3.1, as published by the Free Software Foundation.

// You should have received a copy of the GNU General Public License and
// a copy of the GCC Runtime Library Exception along with this program;
// see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
// <http://www.gnu.org/licenses/>.

#include <bits/c++config.h>
#include <cstdlib>
#include <bits/exception_defines.h>
#include <cxxabi.h>
#include "unwind-cxx.h"

using namespace __cxxabiv1;

#include "unwind-pe.h"


enum exception_entry_type
{
  CATCH_HEADER,
  SPEC_HEADER,
  CONTINUE_UNWINDING_HEADER,
  CLEANUP_HEADER
}; 

static enum exception_entry_type
get_exception_type (int reglen, int regoff)
{
  bool length_bit1;
  bool offset_bit1;

  length_bit1 = reglen & 1;
  offset_bit1 = regoff & 1;

  if (length_bit1 && offset_bit1)
    return SPEC_HEADER;
  else if (length_bit1)
    return CATCH_HEADER;
  else if (offset_bit1)
    return CONTINUE_UNWINDING_HEADER;
  else
    return CLEANUP_HEADER;
}

// Given the thrown type THROW_TYPE, pointer to a variable containing a
// pointer to the exception object THROWN_PTR_P and a type CATCH_TYPE to
// compare against, return whether or not there is a match and if so,
// update *THROWN_PTR_P.

static bool
get_adjusted_ptr (const std::type_info *catch_type,
		  const std::type_info *throw_type,
		  void **thrown_ptr_p)
{
  void *thrown_ptr = *thrown_ptr_p;

  // Pointer types need to adjust the actual pointer, not
  // the pointer to pointer that is the exception object.
  // This also has the effect of passing pointer types
  // "by value" through the __cxa_begin_catch return value.
  if (throw_type->__is_pointer_p ())
    thrown_ptr = *(void **) thrown_ptr;

  if (catch_type->__do_catch (throw_type, &thrown_ptr, 1))
    {
      *thrown_ptr_p = thrown_ptr;
      return true;
    }

  return false;
}
// Save stage1 handler information in the exception object

static inline void
save_caught_exception (struct _Unwind_Exception *ue_header,
		       void *thrown_ptr,
		       int handler_switch_value,
		       const unsigned char *language_specific_data,
		       _Unwind_Ptr landing_pad)
{
  __cxa_exception* xh = __get_exception_header_from_ue(ue_header);

  xh->handlerSwitchValue = handler_switch_value;
  xh->languageSpecificData = language_specific_data;
  xh->adjustedPtr = thrown_ptr;
  xh->catchTemp = landing_pad;
}

// Restore the catch handler information saved during phase1.

static inline void
restore_caught_exception (struct _Unwind_Exception *ue_header,
			  int &handler_switch_value,
			  const unsigned char *& language_specific_data,
			  _Unwind_Ptr& landing_pad)
{
  __cxa_exception* xh = __get_exception_header_from_ue(ue_header);
  handler_switch_value = xh->handlerSwitchValue;
  language_specific_data = xh->languageSpecificData;
  landing_pad = (_Unwind_Ptr) xh->catchTemp;
}
typedef const std::type_info _throw_typet;

static _Unwind_Reason_Code
__gnu_compact_pr_common (int version,
		         _Unwind_Action actions,
		         _Unwind_Exception_Class exception_class,
		         struct _Unwind_Exception *ue_header,
		         struct _Unwind_Context *context, int two_or_three)
{
  const unsigned char *p, *language_specific_data;
  int ehspec_count_offset = 0;
  bool ends_in_catchall;
  enum exception_entry_type etype;
  _Unwind_Ptr reglen, regoff, type_ptr;
  _Unwind_Ptr start, end, ip, landing_pad, lp_start, lp_off;
  _uleb128_t no_of_types;
  int ip_before_insn = 0;
  unsigned int i;
  int handler_switch_value;
  const std::type_info* type_entry;
  void *thrown_ptr = 0;
  _throw_typet *throw_type;
  enum found_handler_type
  {
    found_nothing,
    found_terminate,
    found_cleanup,
    found_handler,
    found_spec
  } found_type = found_nothing;

  bool foreign_exception;
  bool matched_spec;
  unsigned char eh_encoding = _Unwind_GetEhEncoding (context);

  __cxa_exception *xh = __get_exception_header_from_ue(ue_header);
  foreign_exception = !__is_gxx_exception_class(exception_class);

  language_specific_data = (const unsigned char *)
    _Unwind_GetLanguageSpecificData (context);

  // If no LSDA, something has gone wrong.
  if (!language_specific_data)
    return _URC_CONTINUE_UNWIND;

  // Shortcut for phase 2 found handler for domestic exception.
  if (actions == (_UA_CLEANUP_PHASE | _UA_HANDLER_FRAME)
      && !foreign_exception)
    {
      restore_caught_exception (ue_header, handler_switch_value,
				language_specific_data, landing_pad);
      found_type = (landing_pad == 0 ? found_terminate : found_handler);
      goto install_context;
    }
#ifdef _GLIBCXX_HAVE_GETIPINFO
  ip = _Unwind_GetIPInfo (context, &ip_before_insn);
#else
  ip = _Unwind_GetIP (context);
#endif

  if (!ip_before_insn)
    --ip;

  p = (const unsigned char *) language_specific_data;

  /* If this is gnu_compact_pr3, then the landing_pad offset is
     relative to a landing pad start value in the table.
     For gnu_compact_pr2, the landing pad offset is relative to
     the function start.  */
  if (two_or_three == 3)
    p = read_encoded_value (0, DW_EH_PE_sdata4 | DW_EH_PE_pcrel, p, &lp_start);
  else
    lp_start = _Unwind_GetRegionStart (context);
  
  p = read_encoded_value (0, DW_EH_PE_uleb128, p, &reglen);
  if (reglen != 0)
    p = read_encoded_value (0, DW_EH_PE_uleb128, p, &regoff);

  while (reglen != 0)
    {
      etype = get_exception_type (reglen, regoff);
      reglen = reglen & ~1;
      regoff = regoff & ~1;

      start = _Unwind_GetRegionStart (context) + regoff;
      end = start + reglen;

      switch (etype)
	{
	case CLEANUP_HEADER:
	  p = read_encoded_value (context, DW_EH_PE_uleb128, p, &lp_off);

	  if (ip >= start && ip <= end)
	    {
	      landing_pad = lp_start + lp_off;
	      found_type = found_cleanup;
	      handler_switch_value = 0;
	      goto found_something;
	    }
	  break;
	case CONTINUE_UNWINDING_HEADER:
	  if (ip >= start && ip <= end)
	    return _URC_CONTINUE_UNWIND;
	  break;
	case CATCH_HEADER:
#ifdef __GXX_RTTI
	  // During forced unwinding, match a magic exception type.
	  if (actions & _UA_FORCE_UNWIND)
	    {
	      throw_type = &typeid(abi::__forced_unwind);
	    }
	  // With a foreign exception class, there's no exception type.
	  // ??? What to do about GNU Java and GNU Ada exceptions?
	  else if (foreign_exception)
	    {
	      throw_type = &typeid(abi::__foreign_exception);
	    }
	  else
#endif
	    {
	      thrown_ptr = __get_object_from_ue (ue_header);
	      throw_type = __get_exception_header_from_obj
		(thrown_ptr)->exceptionType;
	    }
	  p = read_encoded_value (context, DW_EH_PE_uleb128, p, &lp_off);
	  p = read_uleb128 (p, &no_of_types);
	  ends_in_catchall = no_of_types & 1;
	  no_of_types = no_of_types >> 1;
	  for (i = 0; i < no_of_types; i++)
	    {
	      p = read_encoded_value (context, eh_encoding, p, &type_ptr);
              type_entry = reinterpret_cast<const std::type_info *>(type_ptr);
	      if ((ip >= start && ip <= end)
		   && get_adjusted_ptr (type_entry, throw_type, &thrown_ptr))
		{
		  found_type = found_handler;
		  handler_switch_value = i + 1;
		  landing_pad = lp_start + lp_off;
		  goto found_something;
		}
	    }
	  if (ends_in_catchall && (ip >= start && ip <= end))
	    {
	      found_type = found_handler;
	      handler_switch_value = 0;
	      landing_pad = lp_start + lp_off;
	      goto found_something;
	    }
	  break;
	case SPEC_HEADER:
	  matched_spec = false;
	  p = read_encoded_value (context, DW_EH_PE_uleb128, p, &lp_off);
#ifdef __GXX_RTTI
	  // During forced unwinding, match a magic exception type.
	  if (actions & _UA_FORCE_UNWIND)
	    {
	      throw_type = &typeid(abi::__forced_unwind);
	    }
	  // With a foreign exception class, there's no exception type.
	  // ??? What to do about GNU Java and GNU Ada exceptions?
	  else if (foreign_exception)
	    {
	      throw_type = &typeid(abi::__foreign_exception);
	    }
	  else
#endif
	    {
	      thrown_ptr = __get_object_from_ue (ue_header);
	      throw_type = __get_exception_header_from_obj
		(thrown_ptr)->exceptionType;
	    }

	  /* Save this offset for use by __cxa_call_unexpected. */
	  ehspec_count_offset = (int) (p - language_specific_data);
	  p = read_uleb128 (p, &no_of_types);
	  for (i = 0; i < no_of_types; i++)
	    {
	      p = read_encoded_value (context, eh_encoding, p, &type_ptr);
              type_entry = reinterpret_cast<const std::type_info *>(type_ptr);
	      if (ip >= start && ip <= end)
		{
		  if (get_adjusted_ptr (type_entry, throw_type, &thrown_ptr))
		    {
		      /* When the exception spec matches:
			 1.  Read the rest of the exception spec list
			 2.  Look for a match in the other region entries.  */
		      found_type = found_spec;
		      matched_spec = true;
		      while (++i < no_of_types)
			p = read_encoded_value (context, eh_encoding, p, &type_ptr);
		    }
		}
	    }
	  if (!matched_spec
	      && (ip >= start && ip <= end))
	    {
	      found_type = found_handler;
	      handler_switch_value = -(ehspec_count_offset);
	      landing_pad = lp_start + lp_off;
	      goto found_something;
	    }
	  break;
	}
      p = read_encoded_value (context, DW_EH_PE_uleb128, p, &reglen);
      if (reglen != 0)
	p = read_encoded_value (context, DW_EH_PE_uleb128, p, &regoff);
    }
  if (found_type == found_nothing)
    {
      found_type = found_terminate;
      landing_pad = 0;
    }

found_something:

  if (found_type == found_spec)
    return _URC_CONTINUE_UNWIND;

   if (actions & _UA_SEARCH_PHASE)
    {
      if (found_type == found_cleanup)
	return _URC_CONTINUE_UNWIND;

      if (!foreign_exception)
        {
          save_caught_exception(ue_header, thrown_ptr, handler_switch_value,
				language_specific_data, landing_pad);
        }
      return _URC_HANDLER_FOUND;
    }

install_context:
  
  // We can't use any of the cxa routines with foreign exceptions,
  // because they all expect ue_header to be a struct __cxa_exception.
  // So in that case, call terminate or unexpected directly.
  if ((actions & _UA_FORCE_UNWIND)
      || foreign_exception)
    {
      if (found_type == found_terminate)
	std::terminate ();
      else if (handler_switch_value < 0)
	{
	  __try 
	    { std::unexpected (); } 
	  __catch(...) 
	    { std::terminate (); }
	}
    }
  else
    {
      if (found_type == found_terminate)
	__cxa_call_terminate(ue_header);

      // Cache the base value for __cxa_call_unexpected, as we won't
      // have an _Unwind_Context then.
      if (handler_switch_value < 0)
	{
	  xh->catchTemp = base_of_encoded_value (eh_encoding, context);
	  /* For the compact encoding, bits 0-7 of
	     xh->handler_switch_value are used to store the
	     eh_encoding.  Bits 8-31 of xh_handler_switch_value
	     are used to store the offset from the beginning of
             the LSDA to the type count for this unmatched exception
             specification.  We store this as a positive number to 
	     signal to __cxa_call_unexpected that the LSDA is in 
             the compact format.  */

	  xh->handlerSwitchValue = abs (xh->handlerSwitchValue) << 8;;
	  xh->handlerSwitchValue = xh->handlerSwitchValue | eh_encoding;
	  handler_switch_value = -1;

	}  
    }

  /* For targets with pointers smaller than the word size, we must
     extend the pointer, and this extension is target dependent.  */
  _Unwind_SetGR (context, __builtin_eh_return_data_regno (0),
		 __builtin_extend_pointer (ue_header));
  /* handler_switch_value will always be -1 for an
     unmatched exception spec header.  */
  _Unwind_SetGR (context, __builtin_eh_return_data_regno (1),
		 handler_switch_value);
  _Unwind_SetIP (context, landing_pad);
  return _URC_INSTALL_CONTEXT;
}

namespace __cxxabiv1
{

#pragma GCC visibility push(default)
extern "C" _Unwind_Reason_Code
__gnu_compact_pr2 (int version,
		   _Unwind_Action actions,
		   _Unwind_Exception_Class exception_class,
		   struct _Unwind_Exception *ue_header,
		   struct _Unwind_Context *context)
{
  return __gnu_compact_pr_common (version, actions, exception_class,
				  ue_header, context, 2);
}

extern "C" _Unwind_Reason_Code
__gnu_compact_pr3 (int version,
		   _Unwind_Action actions,
		   _Unwind_Exception_Class exception_class,
		   struct _Unwind_Exception *ue_header,
		   struct _Unwind_Context *context)
{
  return __gnu_compact_pr_common (version, actions, exception_class,
				  ue_header, context, 3);
}

#pragma GCC visibility pop
} // namespace __cxxabiv1

#endif
