package {
	import by.blooddy.crypto.serialization.JSON;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class Howl extends Sprite {
		private var _handler:String;
		private var _sounds:Dictionary;
		private var _loadCount:uint;

		public function Howl() {
			_handler = loaderInfo.parameters.handler || 'SoundHandler';
			_sounds = new Dictionary();

			ExternalInterface.addCallback('playSound', playSound);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, manifestCompleteHandler);
			loader.load(new URLRequest(loaderInfo.parameters.manifest || 'manifest.json'));
		}

		private function manifestCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var manifest:Object = JSON.decode(loader.data);

			_loadCount = 0;

			for each (var entry:Object in manifest) {
				var url:String = entry.url;
				var name:String = url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));

				var sound:SoundClip = new SoundClip();
				sound.name = name;
				sound.loop = entry.loop;
				sound.addEventListener(Event.COMPLETE, soundCompleteHandler);
				sound.load(new URLRequest(url));

				_sounds[name] = sound;
				_loadCount++;
			}
		}

		public function playSound(name:String, loop:Boolean = false):void {
			trace('playSound', name);

			var sound:Sound = _sounds[name];
			sound.play(0, loop ? 9999999 : 0);
		}

		private function soundCompleteHandler(event:Event):void {
			var sound:SoundClip = event.target as SoundClip;
			triggerEvent(event.type, sound.name);

			if (!--_loadCount) {
				triggerEvent(event.type);
			}
		}

		private function triggerEvent(type:String, data:String = null):void {
			trace('Trigger', type, data);

			// SoundHandler.processEvent('childComplete', 'lydA');
			ExternalInterface.call(_handler + '.processEvent', type, data);
		}
	}
}

import flash.media.Sound;

class SoundClip extends Sound {
	public var name:String;
	public var loop:Boolean;
}
