// Higher definition curves
$fs = 0.01;

module roundedcube(size = [1, 1, 1], center = false, radius = 1.0, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = size[2], r = 2*radius, center = true);
		} else if (type == "cube") {
            rotate(a = rotate)
            cube([diameter*2,diameter*2,size[2]], center=true);
        }
	}

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min,translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [size[2]/2]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
                            if (y_at == "max") {
                                    build_point("cylinder", rotate);
                            } else {
                                    build_point("cube", rotate);
							}
						}
					}
				}
			}
            }
	}
}

pl = 9.5;
ph = 12.2;  // 1.0 = space for board
pw = 3.5;
pofs = 7.3; // offset of center point on ph
bofs = 0.8; // space for board
pho = ph - bofs;
rad = 1.0;

magwMountFloor = 0.4;
magwMountGap = 0.2;
magwGapTot = magwMountFloor + magwMountGap;

magw = 2.0;
magod = 6;
magid = 3;

clipfloor = 0.4;
clipfloor_dia = 1.4;

addabit = 0.01;

caseClipCutBase = pw/2;
caseClipCutWidth = 0.3;
caseClipLength = 3.0;
caseClipWidth = 0.75;
caseClipCenter = 0.8;
caseClipHeight = 0.5;

module nub() {
    translate([0,0,0.5]) cylinder(h = 1.0, d = 1.0, center=true);
}

module triangle2(width, height)  {
    rotate([0,-90,0])
    linear_extrude(height = height, center=true, convexity=10)
    polygon([[0,side],[height,0],[0,0]]);
}


// pot shell
/*
union () {
    difference() {
        translate([0,0,pw/2]) union() {
            
            //translate([-pl/2 + 1,-pho/2 + 0.5,pw/2]) nub();
            //translate([-pl/2 + 1,pho/2 - 2.0,pw/2]) nub();
            //translate([pl/2 - 1,pho/2 - 2.0,pw/2]) nub();
            translate([-3.88, 3.75, pw/2]) nub();
            translate([3.88, 3.75, pw/2]) nub();
            translate([-3.88, -4.43, pw/2]) nub();
            translate([0,pho/2 - pofs + bofs,0]) roundedcube(size=[pl - 2 * rad, pho - 2 * rad, pw], center=true, radius = rad, apply_to="z");
        }
        translate([0,0,pw - magw - magwGapTot + addabit]) cylinder(h = magw + magwGapTot, d = magod + 1.6);
        scale([1,1,2]) cylinder(h = (pw-magw - magwGapTot), d = magid + 0.2);
        cylinder(h=clipfloor, d = magid + clipfloor_dia);
        translate([0,-pho/2 - 0.5,0]) scale([1,1.1,1.1]) rotate([0,90,90]) cube([10,3,1.5],center=true);
        translate([-100,-caseClipCenter-caseClipLength/2-caseClipCutWidth, caseClipCutBase]) cube([200, caseClipCutWidth*2 + caseClipLength, 200]);
    }
    translate([pl/2 - caseClipWidth,-caseClipCenter-caseClipLength/2,0]) cube([caseClipWidth, caseClipLength,  pw + caseClipHeight]);
    translate([pl/2 - caseClipWidth,-caseClipCenter,pw+caseClipHeight]) rotate([0,0,-90]) triangle(1.2, 1.1, caseClipLength);
    
    
    translate([-pl/2,-caseClipCenter-caseClipLength/2,0]) cube([caseClipWidth, caseClipLength,  pw + caseClipHeight]);
    translate([-pl/2+caseClipWidth,-caseClipCenter,pw+caseClipHeight]) rotate([0,0,90]) triangle(1.2, 1.1, caseClipLength);
}*/

module magnet(height) {
    difference() {
        cylinder(h = height, d = magod);
        cylinder(h = height, d = magid);
    }
}
module triangle(side, height, width=0)  {
    realwidth = (width == 0) ? side : width;
    rotate([0,-90,0])
    linear_extrude(height = realwidth, center=true, convexity=10)
    polygon([[0,side],[height,0],[0,0]]);
}

// mount
pegWidth = 0.040*25.4;
pegHeight = 0.07*25.4;//0.085 was very hard to put on
pegLength = 0.045*25.4;

mount_h = magw + magwMountFloor;
mount_wall = 1.0;

clip_wall_gap = 0.2;
clip_wall_height = 0;
// translate([0,0,pw]) rotate([0,180,90])


translate([10,0,0])
  {
    difference () {
        union() {   
            cylinder(h = mount_h, d = magod+mount_wall);
            translate([0,0,0]) cylinder(h = pw - clipfloor, d = magid);
            side = (magid/2 - pegHeight/2 + clipfloor_dia/2) - 0.3;
            translate([0,pegHeight/2,pw-clipfloor]) triangle(side,side);
            translate([0,-pegHeight/2,pw-clipfloor]) rotate([180,180,0]) triangle(side,side);
        }
        linear_extrude(mount_h*3) {
            square([pegWidth, pegHeight], center=true);
        }
        linear_extrude(pegLength*.5, scale=[0.4, 0.5]) {
            square([pegWidth*1.4, pegHeight*1.3], center=true);
        }
        translate([0, 0, magwMountFloor]) magnet(magw);
        translate([-pegWidth/2-clip_wall_gap,-magid/2, mount_h - clip_wall_height]) cube([clip_wall_gap, magid, 200]);
        translate([pegWidth/2,-magid/2, mount_h - clip_wall_height]) cube([clip_wall_gap, magid, 200]);
    }
}
