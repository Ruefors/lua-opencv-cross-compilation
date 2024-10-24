#pragma once

// CV_EXPORTS_W : include this file in lua_generated_include

#if defined _WIN32
#  define LUA_CDECL __cdecl
#  define LUA_STDCALL __stdcall
#else
#  define LUA_CDECL
#  define LUA_STDCALL
#endif

#ifndef LUA_EXTERN_C
#  ifdef __cplusplus
#    define LUA_EXTERN_C extern "C"
#  else
#    define LUA_EXTERN_C
#  endif
#endif

#ifndef LUA_EXPORTS
# if (defined _WIN32 || defined WINCE || defined __CYGWIN__) && defined(LUAAPI_EXPORTS)
#   define LUA_EXPORTS __declspec(dllexport)
# elif defined __GNUC__ && __GNUC__ >= 4 && (defined(LUAAPI_EXPORTS) || defined(__APPLE__))
#   define LUA_EXPORTS __attribute__ ((visibility ("default")))
# elif defined __clang__ 
#   define LUA_EXPORTS __attribute__ ((visibility ("default")))
# else
#   define LUA_EXPORTS
# endif
#endif

#ifndef LUAAPI
#  define LUAAPI(rettype) LUA_EXTERN_C LUA_EXPORTS rettype LUA_CDECL
#endif

#ifndef LUA_MODULE_NAME
#error "LUA_MODULE_NAME must be defined"
#endif

#ifndef LUA_MODULE_LIB_NAME
#error "LUA_MODULE_LIB_NAME must be defined"
#endif

#ifndef LUA_MODULE_LIB_VERSION
#error "LUA_MODULE_LIB_VERSION must be defined"
#endif

#define _LUA_TOKEN_CONCAT(A, B) A ## B
#define LUA_TOKEN_CONCAT(A, B) _LUA_TOKEN_CONCAT(A, B)

#define LUA_MODULE_LUAOPEN LUA_TOKEN_CONCAT(luaopen_, LUA_MODULE_NAME)
#define LUA_MODULE_OPEN LUA_TOKEN_CONCAT(open_, LUA_MODULE_NAME)

#define _LUA_TOKEN_STR(A) #A
#define LUA_TOKEN_STR(A) _LUA_TOKEN_STR(A)

#define LUA_MODULE_NAME_STR LUA_TOKEN_STR(LUA_MODULE_NAME)

#ifdef Lua_Module_Func
// keep current value (through OpenCV port file)
#elif defined __GNUC__ || (defined (__cpluscplus) && (__cpluscplus >= 201103))
#define Lua_Module_Func __func__
#elif defined __clang__ && (__clang_minor__ * 100 + __clang_major__ >= 305)
#define Lua_Module_Func __func__
#elif defined(__STDC_VERSION__) && (__STDC_VERSION >= 199901)
#define Lua_Module_Func __func__
#elif defined _MSC_VER
#define Lua_Module_Func __FUNCTION__
#elif defined(__INTEL_COMPILER) && (_INTEL_COMPILER >= 600)
#define Lua_Module_Func __FUNCTION__
#elif defined __IBMCPP__ && __IBMCPP__ >=500
#define Lua_Module_Func __FUNCTION__
#elif defined __BORLAND__ && (__BORLANDC__ >= 0x550)
#define Lua_Module_Func __FUNC__
#else
#define Lua_Module_Func "<unknown>"
#endif

#ifndef LUA_MODULE_QUOTE_STRING2
#define LUA_MODULE_QUOTE_STRING2(x) #x
#endif
#ifndef LUA_MODULE_QUOTE_STRING
#define LUA_MODULE_QUOTE_STRING(x) LUA_MODULE_QUOTE_STRING2(x)
#endif

#ifndef LUA_MODULE_INFO
#define LUA_MODULE_INFO( _message ) do { \
	std::ostringstream _out; _out << _message;  \
	fflush(stdout); fflush(stderr);         \
	fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Info: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
	fflush(stdout); fflush(stderr);         \
} while(0)
#endif

#ifndef LUA_MODULE_WARN
#define LUA_MODULE_WARN( _message ) do { \
	std::ostringstream _out; _out << _message;  \
	fflush(stdout); fflush(stderr);         \
	fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Warning: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
	fflush(stdout); fflush(stderr);         \
} while(0)
#endif

#ifndef LUA_MODULE_ERROR
#define LUA_MODULE_ERROR( _message ) do { \
	std::ostringstream _out; _out << _message;  \
	fflush(stdout); fflush(stderr);         \
	fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
	fflush(stdout); fflush(stderr);         \
} while(0)
#endif

#ifndef LUAL_MODULE_ERROR
#define LUAL_MODULE_ERROR( L, _message ) do { \
	std::ostringstream _out; _out << _message;  \
	luaL_error(L, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
} while(0)
#endif

#ifndef LUAL_MODULE_ERROR_RETURN
#define LUAL_MODULE_ERROR_RETURN( L, _message ) do { \
	std::ostringstream _out; _out << _message;  \
	return luaL_error(L, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
} while(0)
#endif

#ifndef LUA_MODULE_THROW
#define LUA_MODULE_THROW( _message ) do { \
	std::ostringstream _out; _out << _message;  \
	fflush(stdout); fflush(stderr);         \
	fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), "", Lua_Module_Func, __FILE__, __LINE__); \
	fflush(stdout); fflush(stderr);           \
	throw std::runtime_error(_out.str().c_str()); \
} while(0)
#endif

#ifndef LUA_MODULE_ASSERT_THROW
#define LUA_MODULE_ASSERT_THROW( expr, _message ) do { if(!!(expr)) ; else { \
	std::ostringstream _out; _out << _message;  \
	fflush(stdout); fflush(stderr);         \
	fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), #expr, Lua_Module_Func, __FILE__, __LINE__); \
	fflush(stdout); fflush(stderr);         \
	throw std::runtime_error(_out.str().c_str());    \
}} while(0)
#endif

#ifndef LUAL_MODULE_ASSERT
#define LUAL_MODULE_ASSERT( L, expr, _message ) do { if(!!(expr)) ; else { \
	std::ostringstream _out; _out << _message;  \
	luaL_error(L, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: %s (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), _out.str().c_str(), #expr, Lua_Module_Func, __FILE__, __LINE__); \
}} while(0)
#endif

#ifndef LUA_MODULE_ASSERT_SET_HR
#define LUA_MODULE_ASSERT_SET_HR( expr ) do { if(!!(expr)) { hr = S_OK; } else { \
fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), #expr, Lua_Module_Func, __FILE__, __LINE__); \
hr = E_FAIL; } \
} while(0)
#endif

#ifndef LUA_MODULE_ASSERT
#define LUA_MODULE_ASSERT( expr ) do { if(!!(expr)) ; else { \
fflush(stdout); fflush(stderr); \
fprintf(stderr, LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_NAME) "(%s) Error: (%s) in %s, file %s, line %d\n", LUA_MODULE_QUOTE_STRING(LUA_MODULE_LIB_VERSION), #expr, Lua_Module_Func, __FILE__, __LINE__); \
fflush(stdout); fflush(stderr); \
return E_FAIL; } \
} while(0)
#endif

#ifdef __cplusplus
extern "C" {
#endif
#include <lua.h>
#include <lauxlib.h>
#ifdef __cplusplus
}
#endif

#include <algorithm>
#include <array>
#include <concepts>
#include <functional>
#include <initializer_list>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <tuple>
#include <type_traits>
#include <utility>
#include <variant>
#include <vector>

#if (LUA_VERSION_NUM == 501) && !(defined lua_rawlen)
#define lua_rawlen lua_objlen
#endif

#if LUA_VERSION_NUM < 502
#define lua_pushfuncs(L, funcs) luaL_register(L, NULL, funcs)
#else
#define lua_pushfuncs(L, funcs) luaL_setfuncs(L, funcs, 0)
#endif

#if LUA_VERSION_NUM < 504
extern int luaL_typeerror(lua_State* L, int arg, const char* tname);
#endif

namespace LUA_MODULE_NAME {
	// ================================
	// is_usertype generics
	// ================================

	template<typename T>
	struct is_usertype : std::integral_constant<bool, false> {};

	template<typename T>
	constexpr inline bool is_usertype_v = is_usertype<T>::value;

	template<typename T>
	struct usertype_info;

	template<typename T>
	struct is_basetype : std::integral_constant<bool, false> {};

	template<typename T>
	constexpr inline bool is_basetype_v = is_basetype<T>::value;

	template<typename T>
	struct basetype_info;

	template<int Kind>
	struct _Object {
		_Object() = default;
		~_Object() {
			reset();
		}

		_Object(lua_State* L_, int index) : L(L_) {
			if (L != nullptr) {
				lua_pushvalue(L, index);
				ref = luaL_ref(L, LUA_REGISTRYINDEX);
			}
		}

		_Object(const _Object& other) {
			*this = other;
		}

		_Object& operator=(const _Object& other) {
			// Guard self assignment
			if (this == &other) {
				return *this;
			}

			reset();

			if (other.L != nullptr) {
				L = other.L;
				lua_rawgeti(other.L, LUA_REGISTRYINDEX, other.ref);
				ref = luaL_ref(other.L, LUA_REGISTRYINDEX);
			}

			return *this;
		}

		_Object(_Object&& other) noexcept {
			*this = std::move(other);
		}

		_Object& operator=(_Object&& other) noexcept {
			// Guard self assignment
			if (this == &other) {
				return *this;
			}

			reset();

			L = std::exchange(other.L, nullptr); // leave other in valid state
			ref = std::exchange(other.ref, LUA_REFNIL);
			return *this;
		}

		void reset() {
			if (ref != LUA_REFNIL) {
				luaL_unref(L, LUA_REGISTRYINDEX, ref);
				free();
			}
		}

		void free() {
			L = nullptr;
			ref = LUA_REFNIL;
		}

		void assign(lua_State* L, const _Object& other) {
			reset();

			if (L != nullptr) {
				this->L = L;
				lua_push(L, other);
				ref = luaL_ref(L, LUA_REGISTRYINDEX);
			}
		}

		inline bool operator==(const _Object& rhs) const {
			return L == rhs.L && ref == rhs.ref;
		}

		inline bool operator!=(const _Object& rhs) { return !(*this == rhs); }

		lua_State* L = nullptr;
		int ref = LUA_REFNIL;
	};

	using Object = _Object<0>;
	using Table = _Object<1>;
	using Function = _Object<2>;

	const Object lua_nil;
}
