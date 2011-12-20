package aerys.minko.scene.action
{
	import aerys.minko.ns.minko_reflection;
	import aerys.minko.render.effect.reflection.ReflectionType;
	import aerys.minko.render.renderer.IRenderer;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.reflection.ReflectionSurface;
	import aerys.minko.scene.visitor.ISceneVisitor;
	import aerys.minko.type.Factory;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Plane;
	import aerys.minko.type.math.Vector4;
	
	public class ReflectionSurfaceAction implements IAction
	{
		public static const reflectionSurfaceAction : IAction = new ReflectionSurfaceAction();
		
		private static const FACTORY		: Factory = Factory.getFactory(ReflectionData);
		
		private static const TMP_VECTOR_X	: Vector4	= new Vector4();
		private static const TMP_VECTOR_Y	: Vector4	= new Vector4();
		private static const TMP_VECTOR_XY	: Vector4	= new Vector4();
		
		public function get type() : uint
		{
			return ActionType.UPDATE_WORLD_DATA;
		}
		
		public function run(scene		: IScene, 
							visitor		: ISceneVisitor, 
							renderer	: IRenderer) : Boolean
		{
			var reflectionSurface	: ReflectionSurface = ReflectionSurface(scene);
			var localToWorld		: Matrix4x4			= visitor.transformData.world;
			
			localToWorld
				.push()
				.prepend(reflectionSurface.transform);
			
			TMP_VECTOR_X.set(1, 0, 0);
			TMP_VECTOR_Y.set(0, 1, 0);
			TMP_VECTOR_XY.set(1, 1, 0);
			
			localToWorld.transformVector(TMP_VECTOR_X, TMP_VECTOR_X);
			localToWorld.transformVector(TMP_VECTOR_Y, TMP_VECTOR_Y);
			localToWorld.transformVector(TMP_VECTOR_XY, TMP_VECTOR_XY);
			
			var reflectionData : ReflectionData = ReflectionData(FACTORY.create(true));
			reflectionData.plane.setFromTriangle(
				TMP_VECTOR_X.x,  TMP_VECTOR_X.y,  TMP_VECTOR_X.z,
				TMP_VECTOR_Y.x,  TMP_VECTOR_Y.y,  TMP_VECTOR_Y.z,
				TMP_VECTOR_XY.x, TMP_VECTOR_XY.y, TMP_VECTOR_XY.z
			);
			reflectionData.minko_reflection::size = reflectionSurface.size;
			reflectionData.minko_reflection::type = ReflectionType.PLANAR;
			
			if (!visitor.worldData[ReflectionData])
				visitor.worldData[ReflectionData] = new WorldDataList();
			WorldDataList(visitor.worldData[ReflectionData]).push(reflectionData);
			
			visitor.visit(reflectionSurface.mesh);
			
			localToWorld.pop();
			
			return true;
		}
	}
}