package com.slevinbe.springassubviewcontext {
	import org.springextensions.actionscript.ioc.factory.config.IConfigurableListableObjectFactory;
	import org.springextensions.actionscript.stage.StageProcessorFactoryPostprocessor;
	import org.springextensions.actionscript.utils.ApplicationUtils;

	public class RootComponentProcessorFactoryPostProcessor extends StageProcessorFactoryPostprocessor {

		public function RootComponentProcessorFactoryPostProcessor() {
			super();
		}

		/**
		 * Checks if the specified <code>IConfigurableListableObjectFactory</code> implements <code>IOwnerModuleAware</code>, if so
		 * it checks if the <code>ownerModule</code> property is not null and return its value.
		 * <p>Otherwise a reference to the current <code>Application</code> instance is returned.</p>
		 * @param objectFactory
		 * @return Either a reference to a <code>Module</code> or to the current <code>Application</code> instance.
		 */
		override protected function findCurrentDocument(objectFactory:IConfigurableListableObjectFactory):Object {
			var rootComponentAware:IRootComponentAware = (objectFactory as IRootComponentAware);
			if ((rootComponentAware != null) && (rootComponentAware.rootComponent != null)) {
				return rootComponentAware.rootComponent;
			} else {
				return ApplicationUtils.application;
			}
		}
	}
}
