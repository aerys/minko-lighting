package aerys.minko.scene.action
{
	import aerys.minko.render.renderer.IRenderer;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.light.ILight;
	import aerys.minko.scene.visitor.ISceneVisitor;
	
	public class LightAction implements IAction
	{
		private var _lightData	: LightData	= new LightData();
		
		public function get type() : uint
		{
			return ActionType.UPDATE_WORLD_DATA;
		}
		
		public function run(scene : IScene, visitor : ISceneVisitor, renderer : IRenderer) : Boolean
		{
			var light	: ILight		= ILight(scene);
			var data	: LightData		= light.getLightData(visitor.transformData)
			
			if (!data)
				return false;
				
			var list	: WorldDataList	= visitor.worldData[LightData];
			if (!list)
				visitor.worldData[LightData] = list = new WorldDataList();
			
			list.push(data);
			
			return true;
		}
	}
}