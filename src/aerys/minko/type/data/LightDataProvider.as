package aerys.minko.type.data
{
	import aerys.minko.type.enum.DataProviderUsage;

	public class LightDataProvider extends DataProvider
	{
		public function LightDataProvider()
		{
			super(null, 'LightingDataProvider', DataProviderUsage.MANAGED);
		}
	}
}
