import luxe.Sprite;
import luxe.Vector;

import phoenix.geometry.Geometry;

class IsometricMap
{
	var grid : Map<String,Sprite> = new Map<String,Sprite>();

	public var base_width(default, null) : Int;
	public var base_height(default, null) : Int;

	var grid_snap : Int = 1;
	var grid_mult : Int = 1;

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var width_half(default, null) : Int;
	public var height_half(default, null) : Int;

    public function new(?_base_width:Int = 64, ?_base_height:Int = 32, ?_grid_snap:Int = 1)
    {
    	base_width = _base_width;
    	base_height = _base_height;

		set_snap(_grid_snap);
    }

    public function set_snap(snap:Int)
    {
    	if (snap >= 1 && snap <= 4)
    	{
    		grid_mult = (1 << (snap - 1));

    		width = base_width * grid_mult;
    		height = base_height * grid_mult;

    		width_half = Std.int(width / 2);
    		height_half = Std.int(height / 2);

            Luxe.events.queue('IsometricMap.Snap', '$width x $height ($snap)');

    		trace('grid ' + width + 'x' + height + ' - ' + snap);
    	}
    }

    public function get_tile(pos:Vector) : Sprite
    {
    	var k = _key(pos);
        var v = grid.get(k);

        return v;
    }

    public function get_tile_world(pos:Vector) : Sprite
    {
        for (spr in grid)
        {
            if (spr.point_inside_AABB(pos))
            {
                return spr;
            }
        }

        return null;
    }

    public inline function get_depth_str(pos:Vector, actual:Float) : String
    {
        var cur = depth(pos);
        var d = actual - cur;

        if (d == 0)
        {
            return '$cur';
        }
        else if (d > 0)
        {
            return '$cur+$d';
        }
        else
        {
            return '$cur$d';
        }
    } 

    inline function depth(pos:Vector) : Float
    {
        return Math.abs(pos.y) * grid_mult + Math.abs(pos.x) * grid_mult;
    }

    public function set_tile(tile:Sprite, pos:Vector)
    {
        remove_tile(pos);

        //tile.depth = Std.parseFloat(pos.y + '.' + pos.x);
        tile.depth = depth(pos);

        grid.set(_key(pos), tile);

        trace('Place tile at ' + _key(pos) + ' depth = ' + tile.depth);
    }

    public function remove_tile(pos:Vector, ?_destroy:Bool = true) : Bool
    {
        var k = _key(pos);
        var v = grid.get(k);

        if (v != null && _destroy) v.destroy();

        return grid.remove(k);
    }

    inline function _key(p:Vector)
    {
        return Std.int(p.x * grid_mult) + '-' + Std.int(p.y * grid_mult);
    }

    public function change_depth_ofs(pos:Vector, depth:Int) : Bool
    {
        var s = get_tile(pos);
        if (s != null)
        {
            s.depth += depth;
            return true;
        }

        return false;
    }

    public inline function screen_to_iso(p:Vector) : Vector
    {
        /*
        var mx = Std.int(((p.x / width_half) + (p.y / height_half)) / 2);
        var my = Std.int(((p.y / height_half) - (p.x / width_half)) / 2);
        */
        var px = Std.int(p.x / width_half);
        var py = Std.int(p.y / height_half); 

        var mx = Std.int((px + py) / 2);
        var my = Std.int((py - px) / 2);

        return new Vector(mx, my);
    }

    public inline function iso_to_screen(p:Vector) : Vector
    {
        var sx = (p.x - p.y) * width_half;
        var sy = (p.x + p.y) * height_half;

        return new Vector(sx, sy);
    }
}