$Script:PrintixConnection = $null
$Script:PrintixPartnerConnection = $null

# Bridge Span-based comparison for older PowerShell 7 runtimes.
if (-not ('Printix.Cryptography' -as [type])) {
	Add-Type -TypeDefinition @'
namespace Printix {
	public static class Cryptography {
		public static bool FixedTimeEquals(byte[] left, byte[] right) {
			return System.Security.Cryptography.CryptographicOperations.FixedTimeEquals(left, right);
		}
	}
}
'@
}
