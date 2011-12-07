package aerys.minko.scene.action
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.renderer.IRenderer;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.light.AbstractLight;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.scene.visitor.ISceneVisitor;
	import aerys.minko.type.Factory;
	import aerys.minko.type.math.Matrix4x4;
	
	import flash.utils.Dictionary;
	
	use namespace minko_lighting;
	
	public class LightAction implements IAction
	{
		public static const lightAction : LightAction = new LightAction();
		
		private static const FACTORY : Factory = new Factory(LightData);
		
		public function get type() : uint
		{
			return ActionType.UPDATE_WORLD_DATA;
		}
		
		public function run(scene		: IScene, 
							visitor		: ISceneVisitor, 
							renderer	: IRenderer) : Boolean
		{
			var light		: AbstractLight	= AbstractLight(scene);
			var lightData	: LightData		= buildLightData(light, visitor.transformData.world)
			var worldData	: Dictionary	= visitor.worldData;
			
			// add the light data on the AbstractLightData field
			if (worldData[LightData] == undefined)
				worldData[LightData] = new WorldDataList();
			worldData[LightData].push(lightData);
			
			return true;
		}
		
		private function buildLightData(light : AbstractLight, 
										world : Matrix4x4) : LightData
		{
			var lightData : LightData = LightData(FACTORY.create(true));
			
			lightData.minko_lighting::color = light.color;
			lightData.minko_lighting::group = light.group;
			Matrix4x4.copy(world, lightData.lightToWorld);
			
			if (light is AmbientLight)
				buildAmbientLightData(AmbientLight(light), lightData);
			
			else if (light is DirectionalLight)
				buildDirectionalLightData(DirectionalLight(light), lightData);
			
			else if (light is PointLight)
				buildPointLightData(PointLight(light), lightData);
			
			else if (light is SpotLight)
				buildSpotLightData(SpotLight(light), lightData);
			
			return lightData;
		}
		
		private function buildAmbientLightData(light		: AmbientLight,
											   lightData	: LightData) : void
		{
			lightData.minko_lighting::ambient				= light.ambient; 
			lightData.minko_lighting::diffuse				= 0;
			lightData.minko_lighting::distance				= 0;
			lightData.minko_lighting::innerRadius			= 0;
			lightData.minko_lighting::outerRadius			= 0;
			lightData.minko_lighting::shadowMapSize			= 0;
			lightData.minko_lighting::shininess				= 0;
			lightData.minko_lighting::specular				= 0
			lightData.minko_lighting::type					= AmbientLight.TYPE;
			lightData.minko_lighting::useParaboloidShadows	= false;
		}
		
		private function buildDirectionalLightData(light		: DirectionalLight,
												   lightData	: LightData) : void
		{
			lightData.minko_lighting::ambient				= 0; 
			lightData.minko_lighting::diffuse				= light.diffuse;
			lightData.minko_lighting::distance				= 0;
			lightData.minko_lighting::innerRadius			= 0;
			lightData.minko_lighting::outerRadius			= 0;
			lightData.minko_lighting::shadowMapSize			= light.shadowMapSize;
			lightData.minko_lighting::shininess				= light.shininess;
			lightData.minko_lighting::specular				= light.specular;
			lightData.minko_lighting::type					= DirectionalLight.TYPE;
			lightData.minko_lighting::useParaboloidShadows	= false;
		}
		
		private function buildPointLightData(light		: PointLight,
											 lightData	: LightData) : void
		{
			lightData.minko_lighting::ambient				= 0; 
			lightData.minko_lighting::diffuse				= light.diffuse;
			lightData.minko_lighting::distance				= light.distance;
			lightData.minko_lighting::innerRadius			= 0;
			lightData.minko_lighting::outerRadius			= 0;
			lightData.minko_lighting::shadowMapSize			= light.shadowMapSize;
			lightData.minko_lighting::shininess				= light.shininess;
			lightData.minko_lighting::specular				= light.specular;
			lightData.minko_lighting::type					= PointLight.TYPE;
			lightData.minko_lighting::useParaboloidShadows	= light.useParaboloidShadows;
		}
		
		private function buildSpotLightData(light		: SpotLight,
											lightData	: LightData) : void
		{
			lightData.minko_lighting::ambient				= 0; 
			lightData.minko_lighting::diffuse				= light.diffuse;
			lightData.minko_lighting::distance				= light.distance;
			lightData.minko_lighting::innerRadius			= light.innerRadius;
			lightData.minko_lighting::outerRadius			= light.outerRadius;
			lightData.minko_lighting::shadowMapSize			= light.shadowMapSize;
			lightData.minko_lighting::shininess				= light.shininess;
			lightData.minko_lighting::specular				= light.specular;
			lightData.minko_lighting::type					= SpotLight.TYPE;
			lightData.minko_lighting::useParaboloidShadows	= false;
		}
	}
}