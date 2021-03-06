{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2011 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

    Colour Conversion Utilities for the Mufasa Macro Library
}

unit colour_conv;

{$mode objfpc}{$H+}
{$Inline on}

interface

uses
  Classes, SysUtils,
  Graphics, mufasatypes,
  Math;


Function RGBtoColor(r,g,b : byte) : TColor; overload; inline;
Function RGBtoColor(r,g,b : integer) : TColor; overload; inline;
Procedure ColorToRGB(Color : integer;out r,g,b : byte); overload; inline;
Procedure ColorToRGB(Color : integer;out r,g,b : integer); overload; inline;
Procedure RGBToXYZ(R,G,B : byte;out x,y,z : Extended); inline;
Procedure XYZToRGB(X,Y,Z : Extended;out R,G,B: byte); overload; inline;
Procedure XYZToRGB(X,Y,Z : Extended;out R,G,B: integer); overload; inline;
Procedure RGBToHSL(RR,GG,BB : byte;out H,S,L : Extended); inline;
Procedure RGBToHSLNonFixed(RR,GG,BB : byte;out H,S,L : Extended); inline;
Procedure HSLtoRGB(H,S,L : extended;out R,G,B : Byte); inline;
Procedure ColorToHSL(Col: Integer; out h, s, l: Extended); inline;
procedure ColorToXYZ(color: Integer; out X, Y, Z: Extended); inline;
function XYZToColor(X, Y, Z: Extended): TColor; inline;
function HSLToColor(H, S, L: Extended): TColor; inline;
function BGRToRGB(BGR : TRGB32) : TColor; inline;
procedure XYZToHSL(X, Y, Z: Extended; out H, S, L: Extended); inline;
procedure HSLToXYZ(H, S, L: Extended; out X, Y, Z: Extended); inline;
procedure XYZtoCIELab(X, Y, Z: Extended; out L, a, b: Extended);
procedure CIELabtoXYZ(L, a, b: Extended; out X, Y, Z: Extended);
procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: byte); overload;  inline;
procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: integer); overload; inline;
procedure RGBToCIELab(rr, gg, bb: byte; out L, a, b: Extended); overload; inline;
procedure RGBToCIELab(rr, gg, bb: integer; out L, a, b: Extended); overload; inline;
function CIELabToColor(L, a, b: Extended): TColor; inline;
procedure ColorToCIELab(Color: integer; out L, a, b: Extended); inline;
procedure CIELabToHSL(L, a, b: Extended; out HH, SS, LL: Extended); inline;
procedure HSLToCIELab(HH, SS, LL: Extended; out L, a, b: Extended); inline;


implementation

Const
  OneDivThree = 1/3.0;
  TwoDivThree = 2 / 3.0;
  OneDivTwoPointFour = 1 / 2.4;
function BGRToRGB(BGR : TRGB32) : TColor;inline;
begin;
  Result := BGR.R or BGR.g shl 8 or BGR.b shl 16;
end;

Function RGBtoColor(r,g,b : byte): TColor; overload; inline;
begin;
  Result := R or g shl 8 or b shl 16;
end;

{/\
  Translates the given Red (R), Green (G) and Blue (B) components to a TColor.
  R, G and B are integers.
/\}

Function RGBtoColor(r,g,b : integer): TColor; overload; inline;
begin;
  Result := R or g shl 8 or b shl 16;
end;

{/\
   Translates the given win-32 color in the Red (R), Green (G) and Blue (B)
   components. R, G and B are bytes.
/\}

Procedure ColorToRGB(Color : integer;out r,g,b : byte); overload; inline;
begin
  R := Color and $ff;
  G := Color shr 8 and $ff;
  B := Color shr 16 and $ff;
end;

{/\
   Translates the given win-32 color in the Red (R), Green (G) and Blue (B)
   components. R, G and B are integers.
/\}

Procedure ColorToRGB(Color : integer;out r,g,b : integer); overload; inline;
begin
  R := Color and $ff;
  G := Color shr 8 and $ff;
  B := Color shr 16 and $ff;
end;

{/\
   Translates the given Red (R), Green (G) and Blue (B) components to
   X, Y and Z components.
/\}

Procedure RGBToXYZ(R,G,B : byte;out x,y,z : Extended); inline;
var
  Red,Green,Blue : Extended;
begin;
  Red := R / 255;
  Green := G / 255;
  Blue := B / 255;
  if Red > 0.04045  then
    Red := Power( ( Red + 0.055 ) / 1.055  , 2.4)
  else
    Red := Red  / 12.92;
  if Green > 0.04045  then
    Green := Power( ( Green + 0.055 ) / 1.055 , 2.4)
  else
    Green := Green  / 12.92;
  if  Blue > 0.04045 then
    Blue := Power(  ( Blue + 0.055 ) / 1.055  , 2.4)
  else
    Blue := Blue / 12.92;
  X := Red * 0.4124 + Green * 0.3576 + Blue * 0.1805;
  Y := Red * 0.2126 + Green * 0.7152 + Blue * 0.0722;
  Z := Red * 0.0193 + Green * 0.1192 + Blue * 0.9505;
end;

{/\
   Translates the given X, Y and Z components to
   Red (R), Green (G) and Blue (B) components.
/\}

Procedure XYZToRGB(X,Y,Z : Extended;out R,G,B: byte); overload; inline;
var
  TempR,TempG,TempB: Extended;
begin;
  TempR := x *  3.2406 + y * -1.5372 + z * -0.4986;
  TempG := x * -0.9689 + y *  1.8758 + z *  0.0415;
  TempB := x *  0.0557 + y * -0.2040 + z *  1.0570;
  if TempR > 0.0031308  then
    TempR := 1.055 * ( Power(TempR, (OneDivTwoPointFour)) ) - 0.055
  else
    TempR := 12.92 * TempR;
  if TempG > 0.0031308 then
    TempG := 1.055 * ( Power(TempG, ( OneDivTwoPointFour)) ) - 0.055
  else
    TempG := 12.92 * TempG;
  if  TempB > 0.0031308 then
    TempB := 1.055 * ( Power(TempB , ( OneDivTwoPointFour )) ) - 0.055
  else
    TempB := 12.92 * TempB;
  R := Round(TempR * 255);
  G := Round(TempG * 255);
  B := Round(TempB * 255);
end;

Procedure XYZToRGB(X,Y,Z : Extended;out R,G,B: integer); overload; inline;
var
  TempR,TempG,TempB: Extended;
begin;
  TempR := x *  3.2406 + y * -1.5372 + z * -0.4986;
  TempG := x * -0.9689 + y *  1.8758 + z *  0.0415;
  TempB := x *  0.0557 + y * -0.2040 + z *  1.0570;
  if TempR > 0.0031308  then
    TempR := 1.055 * ( Power(TempR, (OneDivTwoPointFour)) ) - 0.055
  else
    TempR := 12.92 * TempR;
  if TempG > 0.0031308 then
    TempG := 1.055 * ( Power(TempG, ( OneDivTwoPointFour)) ) - 0.055
  else
    TempG := 12.92 * TempG;
  if  TempB > 0.0031308 then
    TempB := 1.055 * ( Power(TempB , ( OneDivTwoPointFour )) ) - 0.055
  else
    TempB := 12.92 * TempB;
  R := Round(TempR * 255);
  G := Round(TempG * 255);
  B := Round(TempB * 255);
end;

{/\
   Translates the given Red (R), Green (G) and Blue (B) components to
   H (Hue), S (Saturation) and L (Luminance) components.
/\}

Procedure RGBToHSL(RR,GG,BB : byte;out H,S,L : Extended); inline;
var
  R,  G,  B,   D,  Cmax, Cmin: Extended;
begin
  R := RR / 255;
  G := GG / 255;
  B := BB / 255;
  CMin := R;
  if G < Cmin then Cmin := G;
  if B  < Cmin then Cmin := B;
  CMax := R;
  if G > Cmax then Cmax := G;
  if B  > Cmax then Cmax := B;
  L := 0.5 * (Cmax + Cmin);
  if Cmax = Cmin then
  begin
    H := 0;
    S := 0;
  end else
  begin;
    D := Cmax - Cmin;
    if L < 0.5 then
      S := D / (Cmax + Cmin)
    else
      S := D / (2 - Cmax - Cmin);
    if R = Cmax then
      H := (G - B) / D
    else
      if G = Cmax then
        H  := 2 + (B - R) / D
      else
        H := 4 +  (R - G) / D;
    H := H / 6;
    if H < 0 then
      H := H + 1;
  end;
  H := H * 100;
  S := S * 100;
  L := L * 100;
end;

{/\
   Translates the given Red (R), Green (G) and Blue (B) components to
   H (Hue), S (Saturation) and L (Luminance) components.
   This function does not multiply it by 100.
/\}

Procedure RGBToHSLNonFixed(RR,GG,BB : byte;out H,S,L : Extended); inline;
var
  R,  G,  B,   D,  Cmax, Cmin: Extended;
begin
  R := RR / 255;
  G := GG / 255;
  B := BB / 255;
  CMin := R;
  if G < Cmin then Cmin := G;
  if B  < Cmin then Cmin := B;
  CMax := R;
  if G > Cmax then Cmax := G;
  if B  > Cmax then Cmax := B;
  L := 0.5 * (Cmax + Cmin);
  if Cmax = Cmin then
  begin
    H := 0;
    S := 0;
  end else
  begin;
    D := Cmax - Cmin;
    if L < 0.5 then
      S := D / (Cmax + Cmin)
    else
      S := D / (2 - Cmax - Cmin);
    if R = Cmax then
      H := (G - B) / D
    else
      if G = Cmax then
        H  := 2 + (B - R) / D
      else
        H := 4 +  (R - G) / D;
    H := H / 6;
    if H < 0 then
      H := H + 1;
  end;
end;

{/\
   Translates the given H (Hue), S (Saturation) and L (Luminance) components to
   Red (R), Green (G) and Blue (B) components.
/\}

procedure HSLtoRGB(H, S, L: extended; out R, G, B: Byte); inline;
var
  Temp,Temp2 : Extended;
//begin

Function Hue2RGB(TempHue : Extended) : integer;
begin;
  if TempHue < 0 then
    TempHue := TempHue + 1
  else if TempHue > 1 then
    TempHue := TempHue - 1;
  if ( ( 6 * TempHue ) < 1 ) then
    Result :=Round(255 * (( Temp + ( Temp2 - Temp ) * 6 * TempHue )))
  else if ( ( 2 * TempHue ) < 1 ) then
    Result :=Round(255 * Temp2)
  else if ( ( 3 * TempHue ) < 2 ) then
    Result :=Round(255 * (Temp + ( Temp2 - Temp ) * ( ( TwoDivThree ) - TempHue ) * 6))
  else
    Result :=Round(255 * Temp);
end;

begin;
  H := H / 100;
  S := S / 100;
  L := L / 100;
  if s = 0 then
  begin;
    R := Byte(Round(L * 255));
    G := R;
    B := R;
  end else
  begin;
    if (L < 0.5) then
      Temp2 := L * ( 1 + S )
    else
      Temp2 := (L + S) - ( S * L);
    Temp := 2 * L - Temp2;
    R := Hue2RGB( H + ( OneDivThree ) );
    G := Hue2RGB( H );
    B := Hue2RGB( H - ( OneDivThree ) );
  end;
end;

{/\
  Split the Given Color col in H, S, L components.
/\}

Procedure ColorToHSL(Col: Integer; out h, s, l: Extended); inline;
Var
  R, G, B: byte;
Begin
  ColorToRGB(Col, R, G, B);
  RGBToHSL(R, G, B, H, S, L);
End;

procedure ColorToXYZ(color: Integer; out X, Y, Z: Extended); inline;
var
  R, G, B: byte;
begin
  ColorToRGB(Color, R, G, B);
  RGBToXYZ(R, G, B, X, Y, Z);
end;

function HSLToColor(H, S, L: Extended): TColor; inline;
var
  r, g, b: byte;
begin
  HSLToRGB(H, S, L, r, g, b);
  Result := RGBToColor(r, g, b);
end;

function XYZToColor(X, Y, Z: Extended): TColor; inline;
var
  r, g, b: byte;
begin
  XYZToRGB(X, Y, Z, r, g, b);
  Result := RGBToColor(r, g, b);
end;

procedure XYZToHSL(X, Y, Z: Extended; out H, S, L: Extended); inline;
var
  r, g, b: byte;
begin
  XYZToRGB(X, Y, Z, r, g, b);
  RGBToHSL(r, g, b, H, S, L);
end;

procedure HSLToXYZ(H, S, L: Extended; out X, Y, Z: Extended); inline;
var
  r, g, b: byte;
begin
  HSLToRGB(H, S, L, r, g, b);
  RGBToXYZ(r, g, b, X, Y, Z);
end;

procedure XYZtoCIELab(X, Y, Z: Extended; out L, a, b: Extended);
begin
  X := X / 95.047;
  Y := Y / 100.000;
  Z := Z / 108.883;

  if ( X > 0.008856 ) then
    X := Power(X, 1.0/3.0)
  else
    X := ( 7.787 * X ) + ( 16.0 / 116.0 );
  if ( Y > 0.008856 ) then
    Y := Power(Y, 1.0/3.0)
  else
    Y := ( 7.787 * Y ) + ( 16.0 / 116.0 );
  if ( Z > 0.008856 ) then
    Z := Power(Z, 1.0/3.0)
  else
    Z := ( 7.787 * Z ) + ( 16.0 / 116.0 );

  L := (116.0 * Y ) - 16.0;
  a := 500.0 * ( X - Y );
  b := 200.0 * ( Y - Z );
end;

procedure CIELabtoXYZ(L, a, b: Extended; out X, Y, Z: Extended);
begin
  Y := ( L + 16 ) / 116.0;
  X := ( a / 500.0 )+ Y;
  Z := Y - ( b / 200.0 );

  if ( Power(Y, 3) > 0.008856 ) then
    Y := Power(Y, 3)
  else
    Y := ( Y - (16.0 / 116.0 )) / 7.787;
  if ( Power(X, 3) > 0.008856 ) then
    X := Power(X, 3)
  else
    X := ( X - (16.0 / 116.0) ) / 7.787;
  if ( Power(Z, 3) > 0.008856 ) then
    Z := Power(Z, 3)
  else
    Z := ( Z - (16.0 / 116.0) ) / 7.787;


  X := 95.047 * X;
  Y := 100.000 * Y;
  Z := 108.883 * Z;
end;

procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: byte); overload; inline;
var
  X, Y, Z: Extended;
begin
  CIELabToXYZ(L, a, b, X, Y, Z);
  XYZToRGB(X, Y, Z, rr, gg, bb);
end;

procedure CIELabToRGB(L, a, b: Extended; out rr, gg, bb: integer); overload; inline;
var
  X, Y, Z: Extended;
begin
  CIELabToXYZ(L, a, b, X, Y, Z);
  XYZToRGB(X, Y, Z, rr, gg, bb);
end;

procedure RGBToCIELab(rr, gg, bb: byte; out L, a, b: Extended); overload; inline;
var
  X, Y, Z: Extended;
begin
  RGBToXYZ(rr, gg, bb, X, Y, Z);
  XYZtoCIELab(X, Y, Z, L, a, b);
end;

procedure RGBToCIELab(rr, gg, bb: integer; out L, a, b: Extended); overload; inline;
var
  X, Y, Z: Extended;
begin
  RGBToXYZ(rr, gg, bb, X, Y, Z);
  XYZtoCIELab(X, Y, Z, L, a, b);
end;

function CIELabToColor(L, a, b: Extended): TColor; inline;
var
  X, Y, Z: Extended;
begin
  CIELabToXYZ(L, a, b, X, Y, Z);
  Result := XYZToColor(X, Y, Z);
end;

procedure ColorToCIELab(Color: integer; out L, a, b: Extended); inline;
var
  X, Y, Z: Extended;
begin
  ColorToXYZ(Color, X, Y, Z);
  XYZtoCIELab(X, Y, Z, L, a, b);
end;

procedure CIELabToHSL(L, a, b: Extended; out HH, SS, LL: Extended); inline;
var
  rr, gg, bb: byte;
begin
  CIELabToRGB(L, a, b, rr, gg, bb);
  RGBToHSL(rr, gg, bb, HH, SS, LL);
end;

procedure HSLToCIELab(HH, SS, LL: Extended; out L, a, b: Extended); inline;
var
  rr, gg, bb: byte;
begin
  HSLtoRGB(HH, SS, LL, rr, gg, bb);
  RGBToCIELab(rr, gg, bb, L, a, b);
end;

end.
