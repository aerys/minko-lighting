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
	
	public class LightAction implements IAction
	{
		use namespace minko_lighting;
		
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
			
			lightData._color = light.color;
			lightData._group = light.group;
			Matrix4x4.copy(world, lightData._lightToWorld);
			
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
			lightData._ambient				= light.ambient; 
			lightData._diffuse				= 0;
			lightData._distance				= 0;
			lightData._innerRadius			= 0;
			lightData._outerRadius			= 0;
			lightData._shadowMapSize		= 0;
			lightData._shininess			= 0;
			lightData._specular				= 0
			lightData._type					= AmbientLight.TYPE;
			lightData._useParaboloidShadows	= false;
		}
		
		private function buildDirectionalLightData(light		: DirectionalLight,
												   lightData	: LightData) : void
		{
			lightData._ambient				= 0; 
			lightData._diffuse				= light.diffuse;
			lightData._distance				= 0;
			lightData._innerRadius			= 0;
			lightData._outerRadius			= 0;
			lightData._shadowMapSize		= light.shadowMapSize;
			lightData._shininess			= light.shininess;
			lightData._specular				= light.specular;
			lightData._type					= DirectionalLight.TYPE;
			lightData._useParaboloidShadows	= false;
		}
		
		private function buildPointLightData(light		: PointLight,
											 lightData	: LightData) : void
		{
			lightData._ambient				= 0; 
			lightData._diffuse				= light.diffuse;
			lightData._distance				= light.distance;
			lightData._innerRadius			= 0;
			lightData._outerRadius			= 0;
			lightData._shadowMapSize		= light.shadowMapSize;
			lightData._shininess			= light.shininess;
			lightData._specular				= light.specular;
			lightData._type					= PointLight.TYPE;
			lightData._useParaboloidShadows	= light.useParaboloidShadows;
		}
		
		private function buildSpotLightData(light		: SpotLight,
											lightData	: LightData) : void
		{
			lightData._ambient				= 0; 
			lightData._diffuse				= light.diffuse;
			lightData._distance				= light.distance;
			lightData._innerRadius			= light.innerRadius;
			lightData._outerRadius			= light.outerRadius;
			lightData._shadowMapSize		= light.shadowMapSize;
			lightData._shininess			= light.shininess;
			lightData._specular				= light.specular;
			lightData._type					= SpotLight.TYPE;
			lightData._useParaboloidShadows	= false;
		}
	}
}