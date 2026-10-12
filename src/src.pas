library src;

{$mode unleashed}

uses SysUtils;

procedure pas_hello; cdecl;
begin
    writeln('Hello, world from Pascal !');
end;

exports
    pas_hello name 'pas_hello',
    rtlInit name 'pascal_rtlInit',
    rtlDone name 'pascal_rtlDone';

begin
end.
