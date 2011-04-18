package {
	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;

	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.media.Sound;

	public class Howl extends Sprite {
		protected var queue:LoaderMax;

		private var _handler:String;

		public function Howl() {
			_handler = loaderInfo.parameters.handler || 'SoundHandler';

			ExternalInterface.addCallback('playSound', playSound);

			queue = new LoaderMax();
			queue.addEventListener(LoaderEvent.CHILD_COMPLETE, childCompleteHandler);
			queue.addEventListener(LoaderEvent.COMPLETE, completeHandler);

			var loader:DataLoader = new DataLoader(loaderInfo.parameters.manifest || 'manifest.json');
			loader.addEventListener(LoaderEvent.COMPLETE, manifestCompleteHandler);
			loader.load();
		}

		private function manifestCompleteHandler(event:LoaderEvent):void {
			var manifest:Object = JSON.decode(event.target.content);

			for each (var entry:Object in manifest) {
				var url:String = entry.url;
				entry.autoPlay = false;
				entry.name = url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));

				queue.append(new MP3Loader(url, entry));
			}

			queue.load();
		}

		public function playSound(name:String):void {
			ExternalInterface.call('console.log', 'playSound', name);

			var loader:MP3Loader = queue.getLoader(name) as MP3Loader;
			var sound:Sound = loader.content as Sound;
			sound.play(0, loader.vars.loop ? 9999999 : 0);
		}

		private function childCompleteHandler(event:LoaderEvent):void {
			triggerEvent(event.type, event.target.name);
		}

		private function completeHandler(event:LoaderEvent):void {
			triggerEvent(event.type);
		}

		private function triggerEvent(type:String, data:String = null):void {
			trace('Trigger', type, data);

			// SoundHandler.processEvent('childComplete', 'lydA');
			//ExternalInterface.call(_handler + '.processEvent', type, data);
		}
	}
}