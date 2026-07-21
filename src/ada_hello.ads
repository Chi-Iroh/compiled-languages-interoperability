package ada_hello is
    procedure ada_hello with
        Export,
        Convention => C,
        External_Name => "ada_hello";
end ada_hello;
