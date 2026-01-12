{
  This file is part of the JFLibFP Free Pascal Library.

  Copyright (c) 2025-2026 Giuseppe Ferri <jfinfoit@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  See the file LICENSE, included in this distribution,
  for details about the copyright.

 **********************************************************************}



{*
  Tools for checking status, typically the status relates to a @code(TForm) component.
}
unit StateFormUnit;

{$mode ObjFPC}{$H+}{$J-}{$R+}

interface

uses
  Classes, SysUtils;

type
  {* The current status of the component.}
  TState = (
    {* the state is inconsistent }
    UnCreated,
    {* the component has been created but is not yet initialised }
    Created,
    {* the component has been created and is initialised }
    Ready,
    {* the component is active }
    Focused,
    {* the component is not active }
    UnFocused
  );


  {* Array type for mapping @link(TState) values to strings. }
  TStateArray = array[TState] of String;

const
  {* Array that maps @link(TState) enumeration values to their corresponding string representations. }
  StateArray: TStateArray = ('UnCreated', 'Created', 'Ready', 'Focused', 'UnFocused');


implementation




end.

