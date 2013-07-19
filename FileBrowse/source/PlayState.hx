package; 
#if flash
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.FileReference;
	import flash.net.FileFilter;
#elseif (cpp || neko)
	import systools.Dialogs;
#end

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * ...
 * @author Lars Doucet
 */

class PlayState extends FlxState
{
	private var _text:FlxText;
	private var _button:FlxButton;
	private var _img:FlxSprite;
	
	override public function create():Void 
	{
		FlxG.cameras.bgColor = 0xff888888;
		
		_img = new FlxSprite(0, 0);
		_img.makeGraphic(FlxG.width, FlxG.height, 0xffaaaaaa);
		add(_img);
		
		var _button:FlxButton = new FlxButton(0, 0, "Open Image", _onClick);
		add(_button);
		
		var bw:Float = _button.width + 5;
		_text = new FlxText(bw, 0, FlxG.width-(Std.int(bw)*2), "Click the button to load a PNG or JPG!");
		_text.setFormat(null, 16, FlxColor.WHITE, "center", FlxColor.BLACK, true);
		
		add(_text);
		
		FlxG.mouse.show();
	}
	
	private function _onClick():Void {
		_showFileDialog();
	}
	
	private function _showFileDialog():Void {
		#if flash
			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT, _onSelect, false, 0, true);
			fr.addEventListener(Event.CANCEL, _onCancel, false, 0, true);
			var filters:Array<FileFilter> = new Array<FileFilter>();
			filters.push(new FileFilter("PNG Files", "*.png"));
			filters.push(new FileFilter("JPEG Files", "*.jpg;*.jpeg"));
			fr.browse();
		#elseif (cpp || neko)
			var filters: FILEFILTERS =
			{ count: 2
				, descriptions: ["PNG files", "JPEG files"]
				, extensions: ["*.png","*.jpg;*.jpeg"]	
			};	
			var result:Array<String> = Dialogs.openFile( 
				"Select a file please!"
				, "Please select one or more files, so we can see if this method works"
				, filters
				);	
			_onSelect(result);
		#end
   }
   
   #if flash
		private function _onSelect(e:Event):Void {
			var fr:FileReference = cast(e.target, FileReference);
			_text.text = fr.name;			
			fr.addEventListener(Event.COMPLETE, _onLoad, false, 0, true);			
			fr.load();
		}   		
		private function _onLoad(e:Event):Void {
			var fr:FileReference = e.target;
			fr.removeEventListener(Event.COMPLETE, _onLoad);
						
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImgLoad);
			loader.loadBytes(fr.data);
		}
		
		private function _onImgLoad(e:Event):Void {
			var loaderInfo:LoaderInfo = e.target;
			loaderInfo.removeEventListener(Event.COMPLETE, _onImgLoad);
			var bmp:Bitmap = cast(loaderInfo.content, Bitmap);
			_showImage(bmp.bitmapData);
		}
		
	#elseif (cpp || neko)
		private function _onSelect(arr:Array<String>):Void {	   
			if(arr != null && arr.length > 0){
				_text.text = arr[0];
				var img:BitmapData = BitmapData.load(arr[0]);
				if (img != null) {					
					trace("img = " + img.width + "," + img.height);
					_showImage(img);
				}
			}else {
				_onCancel(null);
			}
		}
	#end
			
	private function _onCancel(e:Event):Void {	   
		_text.text = "Cancelled!";
	}		
	
	private function _showImage(data:BitmapData):Void {
		var data2:BitmapData = _img.pixels.clone();
		var dwidth:Float = _img.width / data.width;
		var dheight:Float = _img.height / data.height;
				
		var scale:Float = dwidth <= dheight ? dwidth : dheight;
		if (scale > 1) { scale = 1;}
		
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, 0xffaaaaaa);
		data2.draw(data, matrix, null, null, null, true);
		_img.pixels = data2;
	}
}