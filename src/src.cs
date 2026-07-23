using System.Runtime.InteropServices;

public static class Hello {
    [UnmanagedCallersOnly(EntryPoint = "cs_hello")]
    public static void cs_hello() {
        Console.WriteLine("Hello, world from C# !");
    }
}
