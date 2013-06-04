package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxObject;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;

/**
 * (C) 2013 Bernhard Reiterer
 */
class GameState extends FlxState
{
	
	private var map : FlxTilemap;
	private var player : FlxSprite;
	
	public static inline var MAP_OFFSET_Y = 128;
	public static inline var TILE_DIM = 16;
	
	private var titleText : FlxText;
	private var titleText2 : FlxText;
	private var helpText : FlxText;
	
	private var timeText : FlxText;
	private var bestTimeText : FlxText;
	
	private var btnDebug : FlxButton;
	
	private var bestTime : Float;
	private var currentTime : Float;
	
	private var started : Bool;
	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		started = false;
		
		bestTime = 0;
		currentTime = 0;
		
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/maps/map1.txt"), "assets/image/platformdependent-tiles.png", TILE_DIM, TILE_DIM, 0, 0, 0, 1);
		map.setTileProperties(2, FlxObject.UP);
		map.setTileProperties(3, 0);
		map.y = MAP_OFFSET_Y;
		add(map);
		
		player = new FlxSprite();
		player.loadGraphic("assets/image/greendude.png", true, true, TILE_DIM, TILE_DIM);
		player.updateFrameData();
		
		player.acceleration.y = 300;
		player.drag.x = 300;
		player.addAnimation("idle", [0]);
		player.addAnimation("walking", [0, 1], 4);
		
		player.maxVelocity.x = 40;
		player.width = 14;
		player.offset.x = 1;
		
		add(player);

		player.play("idle");
		
		titleText = new FlxText(0, 0, 370, "PlatformDependent", 30);
		titleText.color = 0xFF4463FF;
		titleText.scrollFactor.x = 0;
		titleText.scrollFactor.y = 0;
		add(titleText);
		
		titleText2 = new FlxText(370, 0, 270, "v0.1\n(c) 2013 Bernhard Reiterer", 16);
		titleText2.color = 0xFF4463FF;
		titleText2.scrollFactor.x = 0;
		titleText2.scrollFactor.y = 0;
		add(titleText2);
		
		helpText = new FlxText(0, 40, 640, "Walk: LEFT/RIGHT, Stairs: UP", 16);
		helpText.color = 0xFF4463FF;
		helpText.scrollFactor.x = 0;
		helpText.scrollFactor.y = 0;
		add(helpText);
	
		timeText = new FlxText(0, 440, 200, "0.000", 16);
		timeText.color = 0xFF4463FF;
		timeText.scrollFactor.x = 0;
		timeText.scrollFactor.y = 0;
		add(timeText);
		
		bestTimeText = new FlxText(300, 440, 200, "", 16);
		bestTimeText.color = 0xFF4463FF;
		bestTimeText.scrollFactor.x = 0;
		bestTimeText.scrollFactor.y = 0;
		bestTimeText.visible = false;
		add(bestTimeText);
		
		btnDebug = new FlxButton(400, 128, "Toggle Debug", toggleDebug);
		add(btnDebug);
		
		resetPlayerPos();
		started = true;
	}
	
	private function toggleDebug() : Void
	{
		FlxG.visualDebug = !FlxG.visualDebug;
	}
	
	private function resetPlayerPos() : Void
	{
		player.x = 7 * TILE_DIM + player.offset.x;
		player.y = 0 + MAP_OFFSET_Y;
		player.velocity.x = 0;
		player.velocity.y = 0;
		player.acceleration.x = 0;
		if (started)
		{
			bestTimeText.color = 0xFF4463FF;
			if (bestTime > 0)
			{
				if (currentTime < bestTime)
				{
					bestTime = currentTime;
					updateBestTimeText();
				}
			}
			else
			{
				bestTime = currentTime;
				bestTimeText.visible = true;
				updateBestTimeText();
			}
		}
		currentTime = 0;
	}
	
	private function updateTimeText() : Void
	{
		if (bestTime > 0)
		{
			if( currentTime < bestTime)
			{
				timeText.color = 0xFF00FF00;
			}
			else
			{
				timeText.color = 0xFFFF0000;
			}
		}
		timeText.text = timeToString(currentTime);
	}
	
	private function updateBestTimeText() : Void
	{
		bestTimeText.color = 0xFF00FF00;
		bestTimeText.text = "Best: " + timeToString(bestTime);
	}
	
	private function timeToString(timeval : Float) : String
	{
		var intMillis = Std.int(1000 * timeval);
		var secs : Float = intMillis / 1000.0;
		return "" + secs;
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		currentTime += FlxG.elapsed;
		updateTimeText();
		
		FlxG.collide(map, player);
		
		if (FlxG.keys.LEFT)
		{
			player.acceleration.x = -60;
			player.facing = FlxObject.LEFT;
			player.play("walking");
		}
		else 
		if(FlxG.keys.RIGHT)
		{
			player.acceleration.x = 60;
			player.facing = FlxObject.RIGHT;
			player.play("walking");
		}
		else {
			player.acceleration.x = 0;
			player.play("idle");
		}
		if (FlxG.keys.UP && map.getTile(Std.int((player.x + 7)/ TILE_DIM), Std.int((player.y -MAP_OFFSET_Y)/ TILE_DIM)) == 3) 
		{
			resetPlayerPos();
		}
		super.update();
	}	
}
