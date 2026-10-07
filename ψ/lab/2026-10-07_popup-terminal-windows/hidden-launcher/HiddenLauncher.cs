using System;
using System.Diagnostics;
using System.Text;

// Compiled as a WinExe (target:winexe) so Windows never allocates a console
// for THIS process at all -- there is nothing to flash, unlike powershell.exe
// -WindowStyle Hidden on an InteractiveToken Scheduled Task, which still
// briefly flashes a console before the hidden style applies.
//
// Usage: HiddenLauncher.exe <program> <arg1> <arg2> ...
// Each argument is re-quoted using the same rules the .NET BCL uses for
// ProcessStartInfo.ArgumentList (not available in this older Framework's
// reference assemblies, so reimplemented here) before being joined into the
// Arguments string, so quoting/escaping round-trips exactly.
// The child process is started with CreateNoWindow + UseShellExecute=false
// so it inherits no console either. Exit code is propagated.
class HiddenLauncher
{
    static void AppendArgument(StringBuilder sb, string argument)
    {
        if (sb.Length != 0) sb.Append(' ');

        if (argument.Length != 0 && argument.IndexOfAny(new char[] { ' ', '\t', '\n', '\v', '"' }) == -1)
        {
            sb.Append(argument);
            return;
        }

        sb.Append('"');
        int idx = 0;
        while (idx < argument.Length)
        {
            char c = argument[idx++];
            if (c == '\\')
            {
                int numBackSlash = 1;
                while (idx < argument.Length && argument[idx] == '\\')
                {
                    idx++;
                    numBackSlash++;
                }
                if (idx == argument.Length)
                {
                    sb.Append('\\', numBackSlash * 2);
                }
                else if (argument[idx] == '"')
                {
                    sb.Append('\\', numBackSlash * 2 + 1);
                    sb.Append('"');
                    idx++;
                }
                else
                {
                    sb.Append('\\', numBackSlash);
                }
            }
            else if (c == '"')
            {
                sb.Append('\\').Append('"');
            }
            else
            {
                sb.Append(c);
            }
        }
        sb.Append('"');
    }

    static int Main(string[] args)
    {
        if (args.Length < 1)
        {
            return 87; // ERROR_INVALID_PARAMETER
        }

        StringBuilder argSb = new StringBuilder();
        for (int i = 1; i < args.Length; i++)
        {
            AppendArgument(argSb, args[i]);
        }

        ProcessStartInfo psi = new ProcessStartInfo
        {
            FileName = args[0],
            Arguments = argSb.ToString(),
            UseShellExecute = false,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        };

        try
        {
            using (Process p = Process.Start(psi))
            {
                p.WaitForExit();
                return p.ExitCode;
            }
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.ToString());
            return 1;
        }
    }
}
