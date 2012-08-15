package aerys.minko.scene.node.data
{
	import aerys.minko.type.enum.DataProviderUsage;
	import aerys.minko.type.binding.DataProvider;

	public class LightDataProvider extends DataProvider
	{
		public function LightDataProvider()
		{
			super(null, 'LightingDataProvider', DataProviderUsage.MANAGED);
		}
	}
}
