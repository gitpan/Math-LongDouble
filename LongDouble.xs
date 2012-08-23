
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdlib.h>

#ifndef LONG_DOUBLE_DECIMAL_PRECISION
#define LONG_DOUBLE_DECIMAL_PRECISION 20
#endif 

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

int _is_nan(long double x) {
    if(x != x) return 1;
    return 0;
}

int  _is_inf(long double x) {
     if(x != x) return 0; /* NaN  */
     if(x == 0.0L) return 0; /* Zero */
     if(x/x != x/x) {
       if(x < 0.0L) return -1;
       else return 1;
     }
     return 0; /* Finite Real */
}

int  _is_zero(long double x) {
     char * buffer;

     if(x != 0.0L) return 0;

     buffer = malloc(2 * sizeof(char));

     sprintf(buffer, "%.0Lf", x);

     if(!strcmp(buffer, "-0")) {
       free(buffer);
       return -1;
     }   

     free(buffer);
     return 1;
}

long double _get_inf(int sign) {
    long double ret;
    ret = 1.0L / 0.0L;
    if(sign < 0) ret *= -1.0L;
    return ret;    
}

long double _get_nan(int sign) {
     long double ret, inf = _get_inf(1);
     if(sign < 1) return -(inf / inf);
     return inf / inf;
}

SV * InfLD(int sign) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in InfLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = _get_inf(sign);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * NaNLD(int sign) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in InfLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = _get_nan(sign);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * ZeroLD(int sign) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in ZeroLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = 0.0L;
     if(sign < 0) *ld *= -1;

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UnityLD(int sign) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in UnityLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = 1.0L;
     if(sign < 0) *ld *= -1;

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

int is_NaNLD(SV * b) {
     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble"))
         return _is_nan(*(INT2PTR(long double *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::LongDouble::isNaNLD function");
}

int is_InfLD(SV * b) {
     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble"))
         return _is_inf(*(INT2PTR(long double *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::LongDouble::is_InfLD function");
}

int is_ZeroLD(SV * b) {
     if(sv_isobject(b)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble"))
         return _is_zero(*(INT2PTR(long double *, SvIV(SvRV(b)))));
     }
     croak("Invalid argument supplied to Math::LongDouble::is_ZeroLD function");
}

SV * STRtoLD(char * str) {
     long double * ld;
     SV * obj_ref, * obj;
     char * ptr;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in STRtoLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = strtold(str, &ptr);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

void LDtoSTR(SV * ld) {
     dXSARGS;
     long double t;
     char * buffer;

     if(sv_isobject(ld)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(ld))), "Math::LongDouble")) {
          EXTEND(SP, 1);
          t = *(INT2PTR(long double *, SvIV(SvRV(ld))));

          buffer = malloc(40 * sizeof(char));
          sprintf(buffer, "%.*Le", LONG_DOUBLE_DECIMAL_PRECISION - 1, t);
          ST(0) = sv_2mortal(newSVpv(buffer, 0));
          free(buffer);
          XSRETURN(1);
       }
       else croak("Invalid object supplied to Math::LongDouble::LDtoSTR function");
     }
     else croak("Invalid argument supplied to Math::LongDouble::LDtoSTR function");
}

SV * NVtoLD(SV * x) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in NVtoLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = (long double)SvNV(x);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * UVtoLD(SV * x) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in UVtoLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = (long double)SvUV(x);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * IVtoLD(SV * x) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in IVtoLD() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     *ld = (long double)SvIV(x);

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * LDtoNV(SV * ld) {
     return newSVnv((NV)(*(INT2PTR(long double *, SvIV(SvRV(ld))))));
}

SV * _overload_add(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_add() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *ld = *(INT2PTR(long double *, SvIV(SvRV(a)))) + *(INT2PTR(long double *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_add function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_add function");
}

SV * _overload_mul(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_mul() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *ld = *(INT2PTR(long double *, SvIV(SvRV(a)))) * *(INT2PTR(long double *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_mul function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_mul function");
}

SV * _overload_sub(SV * a, SV * b, SV * third) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_sub() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *ld = *(INT2PTR(long double *, SvIV(SvRV(a)))) - *(INT2PTR(long double *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_sub function");
    }

    else {
      if(third == &PL_sv_yes) {
        *ld = *(INT2PTR(long double *, SvIV(SvRV(a)))) * -1.0L;
        return obj_ref;
      }
    }

    croak("Invalid argument supplied to Math::LongDouble::_overload_sub function");

}

SV * _overload_div(SV * a, SV * b, SV * third) {
     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_div() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *ld = *(INT2PTR(long double *, SvIV(SvRV(a)))) / *(INT2PTR(long double *, SvIV(SvRV(b))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_div function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_div function");
}

int _overload_equiv(SV * a, SV * b, SV * third) {
    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) == *(INT2PTR(long double *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_equiv function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_equiv function");
}

int _overload_not_equiv(SV * a, SV * b, SV * third) {
    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) == *(INT2PTR(long double *, SvIV(SvRV(b))))) return 0;
        return 1; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_not_equiv function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_not_equiv function");
}

int _overload_true(SV * a, SV * b, SV * third) {

     if(_is_nan(*(INT2PTR(long double *, SvIV(SvRV(a)))))) return 0;
     if(*(INT2PTR(long double *, SvIV(SvRV(a)))) != 0.0L) return 1;
     return 0; 
}

int _overload_not(SV * a, SV * b, SV * third) {
     if(_is_nan(*(INT2PTR(long double *, SvIV(SvRV(a)))))) return 1;
     if(*(INT2PTR(long double *, SvIV(SvRV(a)))) != 0.0L) return 0;
     return 1; 
}

SV * _overload_add_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *(INT2PTR(long double *, SvIV(SvRV(a)))) += *(INT2PTR(long double *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::LongDouble::_overload_add_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::LongDouble::_overload_add_eq function");
}

SV * _overload_mul_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *(INT2PTR(long double *, SvIV(SvRV(a)))) *= *(INT2PTR(long double *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::LongDouble::_overload_mul_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::LongDouble::_overload_mul_eq function");
}

SV * _overload_sub_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *(INT2PTR(long double *, SvIV(SvRV(a)))) -= *(INT2PTR(long double *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::LongDouble::_overload_sub_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::LongDouble::_overload_sub_eq function");
}

SV * _overload_div_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *(INT2PTR(long double *, SvIV(SvRV(a)))) /= *(INT2PTR(long double *, SvIV(SvRV(b))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::LongDouble::_overload_div_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::LongDouble::_overload_div_eq function");
}

int _overload_lt(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) < *(INT2PTR(long double *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_lt function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_lt function");
}

int _overload_gt(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) > *(INT2PTR(long double *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_gt function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_gt function");
}

int _overload_lte(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) <= *(INT2PTR(long double *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_lte function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_lte function");
}

int _overload_gte(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) >= *(INT2PTR(long double *, SvIV(SvRV(b))))) return 1;
        return 0; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_gte function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_gte function");
}

SV * _overload_spaceship(SV * a, SV * b, SV * third) {

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) < *(INT2PTR(long double *, SvIV(SvRV(b))))) return newSViv(-1);
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) > *(INT2PTR(long double *, SvIV(SvRV(b))))) return newSViv(1);
        if(*(INT2PTR(long double *, SvIV(SvRV(a)))) == *(INT2PTR(long double *, SvIV(SvRV(b))))) return newSViv(0);
        return &PL_sv_undef; /* it's a nan */  
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_spaceship function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_spaceship function");
}

SV * _overload_copy(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_copy() function");

     *ld = *(INT2PTR(long double *, SvIV(SvRV(a))));

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * LDtoLD(SV * a) {
     long double * ld;
     SV * obj_ref, * obj;

     if(sv_isobject(a)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::LongDouble")) {

         Newx(ld, 1, long double);
         if(ld == NULL) croak("Failed to allocate memory in LDtoLD() function");

         *ld = *(INT2PTR(long double *, SvIV(SvRV(a))));

         obj_ref = newSV(0);
         obj = newSVrv(obj_ref, "Math::LongDouble");
         sv_setiv(obj, INT2PTR(IV,ld));
         SvREADONLY_on(obj);
         return obj_ref;
       }
       croak("Invalid object supplied to Math::LongDouble::LDtoLD function"); 
     }
     croak("Invalid argument supplied to Math::LongDouble::LDtoLD function");
}

SV * _itsa(SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(a))), "Math::LongDouble")) return newSVuv(96);
     }
     return newSVuv(0);
}

void DESTROY(SV *  rop) {
     Safefree(INT2PTR(long double *, SvIV(SvRV(rop))));
}

SV * _overload_abs(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_abs() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

     *ld = *(INT2PTR(long double *, SvIV(SvRV(a))));
     if(_is_zero(*ld) < 0 || *ld < 0 ) *ld *= -1.0L;
     return obj_ref; 
}

SV * cmp_NV(SV * ld_obj, SV * sv) {
     long double ld;
     NV nv;
 
     if(sv_isobject(ld_obj)) {
       if(strEQ(HvNAME(SvSTASH(SvRV(ld_obj))), "Math::LongDouble")) {    
         ld = *(INT2PTR(long double *, SvIV(SvRV(ld_obj))));
         nv = SvNV(sv);

         if((ld != ld) || (nv != nv)) return &PL_sv_undef;
         if(ld < (long double)nv) return newSViv(-1);
         if(ld > (long double)nv) return newSViv(1);
         return newSViv(0);
       }
       croak("Invalid object supplied to Math::LongDouble::cmp_NV function"); 
     }
     croak("Invalid argument supplied to Math::LongDouble::cmp_NV function");
}

int _double_size(void) {
    return sizeof(double);
}

int _long_double_size(void) {
    return sizeof(long double);
}

SV * _overload_int(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_int() function");

     *ld = *(INT2PTR(long double *, SvIV(SvRV(a))));

     if(*ld < 0.0L) *ld = ceill(*ld);
     else *ld = floorl(*ld);

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_sqrt(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_sqrt() function");

     *ld = sqrtl(*(INT2PTR(long double *, SvIV(SvRV(a)))));
 
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_log(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_log() function");

     *ld = logl(*(INT2PTR(long double *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_exp(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_exp() function");

     *ld = expl(*(INT2PTR(long double *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_sin(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_sin() function");

     *ld = sinl(*(INT2PTR(long double *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_cos(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_cos() function");

     *ld = cosl(*(INT2PTR(long double *, SvIV(SvRV(a)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_atan2(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_atan2() function");

     *ld = atan2l(*(INT2PTR(long double *, SvIV(SvRV(a)))), *(INT2PTR(long double *, SvIV(SvRV(b)))));
     

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");
     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);
     return obj_ref; 
}

SV * _overload_inc(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(long double *, SvIV(SvRV(a)))) += 1.0L;

     return a;
}

SV * _overload_dec(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

     *(INT2PTR(long double *, SvIV(SvRV(a)))) -= 1.0L;

     return a;
}

SV * _overload_pow(SV * a, SV * b, SV * third) {

     long double * ld;
     SV * obj_ref, * obj;

     Newx(ld, 1, long double);
     if(ld == NULL) croak("Failed to allocate memory in _overload_pow() function");

     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::LongDouble");

     sv_setiv(obj, INT2PTR(IV,ld));
     SvREADONLY_on(obj);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *ld = powl(*(INT2PTR(long double *, SvIV(SvRV(a)))), *(INT2PTR(long double *, SvIV(SvRV(b)))));
        return obj_ref; 
      }
      croak("Invalid object supplied to Math::LongDouble::_overload_pow function");
    }
    croak("Invalid argument supplied to Math::LongDouble::_overload_pow function");
}

SV * _overload_pow_eq(SV * a, SV * b, SV * third) {

     SvREFCNT_inc(a);

    if(sv_isobject(b)) {
      if(strEQ(HvNAME(SvSTASH(SvRV(b))), "Math::LongDouble")) {
        *(INT2PTR(long double *, SvIV(SvRV(a)))) = powl(*(INT2PTR(long double *, SvIV(SvRV(a)))),
                                                        *(INT2PTR(long double *, SvIV(SvRV(b)))));
        return a;
      }
      SvREFCNT_dec(a);
      croak("Invalid object supplied to Math::LongDouble::_overload_pow_eq function");
    }
    SvREFCNT_dec(a);
    croak("Invalid argument supplied to Math::LongDouble::_overload_pow_eq function");
}

SV * _wrap_count(void) {
     return newSVuv(PL_sv_count);
}

SV * _precision(void) {
    return newSVuv(LONG_DOUBLE_DECIMAL_PRECISION);
}
MODULE = Math::LongDouble	PACKAGE = Math::LongDouble	

PROTOTYPES: DISABLE


SV *
InfLD (sign)
	int	sign

SV *
NaNLD (sign)
	int	sign

SV *
ZeroLD (sign)
	int	sign

SV *
UnityLD (sign)
	int	sign

int
is_NaNLD (b)
	SV *	b

int
is_InfLD (b)
	SV *	b

int
is_ZeroLD (b)
	SV *	b

SV *
STRtoLD (str)
	char *	str

void
LDtoSTR (ld)
	SV *	ld
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	LDtoSTR(ld);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
NVtoLD (x)
	SV *	x

SV *
UVtoLD (x)
	SV *	x

SV *
IVtoLD (x)
	SV *	x

SV *
LDtoNV (ld)
	SV *	ld

SV *
_overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_not_equiv (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_true (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_not (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_lt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_gt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_lte (a, b, third)
	SV *	a
	SV *	b
	SV *	third

int
_overload_gte (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_spaceship (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_copy (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
LDtoLD (a)
	SV *	a

SV *
_itsa (a)
	SV *	a

void
DESTROY (rop)
	SV *	rop
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	DESTROY(rop);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */

SV *
_overload_abs (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
cmp_NV (ld_obj, sv)
	SV *	ld_obj
	SV *	sv

int
_double_size ()
		

int
_long_double_size ()
		

SV *
_overload_int (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sqrt (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_log (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_exp (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_sin (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_cos (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_atan2 (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_inc (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_dec (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_pow (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_overload_pow_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third

SV *
_wrap_count ()
		

SV *
_precision ()
		

