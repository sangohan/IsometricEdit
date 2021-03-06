package editor.behaviors;

import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import phoenix.Batcher;
import phoenix.geometry.Geometry;

import snow.system.input.Keycodes;

import gamelib.TileSheetAtlased;
import gamelib.MyUtils;

import Main;

class TileSelectorBehavior extends Component
{
	var sheet : TileSheetAtlased;
	var sprite : Sprite;
	var batcher : Batcher;
	var indicator : Array<Geometry>;

	public function new(_sheet:TileSheetAtlased, _batcher:Batcher, ?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		indicator = new Array<Geometry>();

		sheet = _sheet;
		batcher = _batcher;
	}

	override public function init()
	{
		sprite = cast entity;

		create_indicators();
	}

	override function onremoved()
	{
		destroy_indicators();
	}

	public function set_sheet(_sheet:TileSheetAtlased)
	{
		destroy_indicators();
		sheet = _sheet;

		sprite.texture = sheet.image;
		sprite.size = new Vector(sheet.image.width, sheet.image.height);
		create_indicators();
	}

	function create_indicators()
	{
		for (tile in sheet.atlas)
		{
			var r = tile.rect;

			var g = Luxe.draw.box({
				x: r.x,
				y: r.y,
				w: r.w,
				h: r.h,
				color : new luxe.Color(1, 1, 1, 0.5),
				visible: false,
				batcher: batcher,
				depth: sprite.depth + 1
				});

			indicator.push(g);
		}
	}

	function destroy_indicators()
	{
		while (indicator != null && indicator.length > 0)
		{
			batcher.remove(indicator.pop());
		}
	}

	public function show_indicators(a:Array<Int>)
	{
		for (idx in a)
		{
			if (idx >= 0 && idx < indicator.length)
			{
				indicator[idx].visible = true;
			}
		}
	}

	public function hide_indicators()
	{
		for (g in indicator)
		{
			g.visible = false;
		}
	}

	override function onmousemove(e:luxe.MouseEvent)
	{
		//trace("I think I found pos " + find_tile(e.pos));
	}

	override function onmouseup(e:luxe.MouseEvent)
	{
		var wpos = batcher.view.screen_point_to_world(e.pos);

		var new_tile = -1;

		if (sprite != null)
		{
			new_tile = sheet.get_tile_idx(wpos, sprite.transform.scale);
		}

		//trace("I think I found pos " + new_tile);

		var sel_event : SelectEvent = { index: new_tile, tilesheet: sheet.index, group: null };

		if (e.button == MouseButton.left)
		{
			Luxe.events.fire('select', sel_event);
		}
		else if (e.button == MouseButton.right)
		{
			Luxe.events.fire('detail', sel_event);
		}
	}

	override function onkeyup(e:luxe.KeyEvent)
	{
        if (!MyUtils.valid_group_key(e))
        {
        	return;
        }

		var wpos = batcher.view.screen_point_to_world(Luxe.screen.cursor.pos);
		var new_tile = sheet.get_tile_idx(wpos);

		var group_name = Keycodes.name(e.keycode);

		var sel_event : SelectEvent = { index: new_tile, tilesheet: sheet.index, group: group_name };

		Luxe.events.fire('assign', sel_event);
	}		
}