%
% PostScript prologue for pst-optexp.tex.
% version 1.0 2011-04-01 (cb)
% For distribution, see pstricks.tex.
%
/tx@OptexpDict 60 dict def
tx@OptexpDict begin
% concatenate two string
% (str1) (str2) -> (str1str2)
/strcat {
    exch 2 copy
    length exch length add
    string dup dup 5 2 roll
    copy length exch
    putinterval
} bind def
% convert a literal name to string
/nametostring {
    dup length string cvs
} bind def
%
% XB YB  XA YA XG YG
/calcNodes {
    /YG exch def /XG exch def
    /ay YG 3 -1 roll sub def
    /ax XG 3 -1 roll sub def
    /by exch YG sub def
    /bx exch XG sub def
    /a ax ay Pyth def
    /modA a def % for external use
    /b bx by Pyth def
    /cx ax a div bx b div add def
    /cy ay a div by b div add def
    /c@tmp cx cy Pyth def
    /c ax bx add ay by add Pyth def
    /OEangle c dup mul a dup mul sub b dup mul sub -2 a b mul mul div Acos def
    %
    % if c=0, then set the coordinates of the vector manually
    % depending on the dotproduct (and thus, if 'a' and 'b'
    % are parallel or antiparallel
    c 0 eq {
	ax bx mul ay by mul add 0 gt {
            % if dotprod > 0 then a and b are parallel
	    /cx ax def
	    /cy ay def
	}{% else a and b are antiparallel
          /cx ay def
          /cy ax neg def
	} ifelse
        /c@tmp a def
    } if
    /X@A XG cx c@tmp div add def
    /Y@A YG cy c@tmp div add def
    /X@B XG cx c@tmp div sub def
    /Y@B YG cy c@tmp div sub def
    %
    % chirality:
    % test the order of the input points as a input angle > 90°
    % doesn't really make sens.
    % So if 'chir' <= 0 exchange the calculated coordinates of 
    % A and B and otherwise leave it as is
    /chirality ax by mul ay bx mul sub def
    chirality 0 le {
	Y@A X@A 
        /X@A X@B def
        /Y@A Y@B def
        /X@B exch def
        /Y@B exch def
    }if
} bind def
% Calculate the height a1 of a pole cap
% R1 height -> a1
/segLen {% 
    dup mul neg exch abs dup 3 1 roll dup mul add sqrt sub
} bind def
% Calculate some parameters for the left plane of a convex lens.
% Defines /a1 as the pole height and /ArcL which are used later in the code.
%
% height R1 -> y |R1| alpha_bottom alpha_top R1
/leftConvex {
   /R1 exch def /h exch def
   /a1  R1 h segLen def
   0 R1 abs
   R1 a1 sub neg dup
   h exch atan exch
   h neg exch atan
   /ArcL /arc load def
   R1
} bind def
% Analogous to /leftConvex
% height R1 -> y |R1| alpha_bottom alpha_top R1
/leftConcave {
   /R1 exch def /h exch def
   /a1 R1 h segLen def
   0 R1 abs
   R1 neg a1 sub dup
   h exch atan exch
   h neg exch atan
   /ArcL /arcn load def
   /a1 0.5 a1 mul def
   R1
} bind def
% Analogous to /leftConvex, /a2 and /ArcR are defined
% height R2 -> y |R2| alpha_bottom alpha_top R2
/rightConvex {
   /R2 exch def /h exch def
   /a2 R2 h segLen def
   0 R2 abs
   R2 a2 sub dup
   h neg exch atan exch
   h exch atan
   R2
   /ArcR /arc load def
} bind def
% Analogous to /rightConvex
% height R2 -> y |R2| alpha_bottom alpha_top R2
/rightConcave {
   /R2 exch def /h exch def
   /a2 R2 h segLen def
   0 R2 abs
   R2 a2 add dup
   h neg exch atan exch
   h exch atan
   /ArcR /arcn load def
   /a2 0.5 a2 mul def
   R2
} bind def
% Calculate the center between two nodes 
% x1 y1 x2 y2 -> (x1+x2)/2 (y1+y2)/2
/mwNode {
    exch 3 1 roll add 2 div 3 1 roll add 2 div exch
} bind def
% Calculate angle of a line from nodeA to nodeB. nodeA and nodeB must be given as literal names
% nodeB nodeA -> angle
/FiberAngleB {%
    @GetCenter 3 -1 roll @GetCenter exch 3 1 roll sub 3 1 roll sub atan
} bind def
%
% Calculate angle of line from nodeB to nodeA
% nodeB nodeA -> angle
/FiberAngleA {%
    FiberAngleB 180 add
} bind def
%
/ExtNode {%
    @@x0 @xref @@x mul add 
    @@y0 @yref @@y mul add 
} bind def
%
% Push all internal node names of (basicnodename) on the stack.
% (basicnodename) reverse GetInternalNodeNames
/GetInternalNodeNames {
    /reverse exch def
    (N@) exch strcat 
    1 % counter
    {% counter and name on stack
	2 copy dup 3 string cvs 3 -1 roll exch strcat dup
	tx@NodeDict exch known {%
	    reverse {
		4 1 roll pop
	    } {
		exch 2 add 1 roll
	    } ifelse
	} {
	    reverse {
		pop pop pop (N) strcat
	    } {
		pop pop exch (N) strcat exch 1 roll
	    } ifelse
	    exit
	} ifelse
	1 add
    } loop
} bind def
%
% (basicnodename) reverse -> x_n y_n ... x_1 y_1 (if reverse = false)
/GetInternalBeamNodes {
    [ 3 1 roll GetInternalNodeNames ]
    { @GetCenter } forall
} bind def
%
% Initialize some global variables for positioning of external nodes
% This is called at the beginning of _every_ component
/InitOptexpComp {%
    tx@Dict begin
	/@@x 0 def
	/@@y 0 def
	/@@x0 0 def
	/@@y0 0 def
        /@xref 0 def
        /@yref 0 def
    end
} bind def
%
% xa ya xb yb ExchCoor true|false
/ExchCoor {
    exch 4 -1 roll 2 copy 
    gt {
	pop pop pop pop false
    } {% xB > xA
	eq % xA == xB
	3 1 roll gt % yA < yB
	and {
	    false
	} {
	    true
	} ifelse
    } ifelse
} bind def
%
% added for version 3.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% {x y} {dx dy} Name {scaling procedure}
/NewTempNodeComp {
  /sc ED
  dup cvn
  6 dict dup 3 1 roll def begin
      /ambiguous false def	
      /name ED
      {0 0} exch 3 -1 roll exec
      gsave
	  translate
	  /CompMtrx CM def
      grestore
      /N 1 def
      /n 1 def
      5 dict dup dup /P@1 ED /P@N ED
      begin
	  /mode trans def
	  {} NewPlaneInt
      end
      /adjustRel true def
  end
} bind def
%[ { x y } { dx dy | rx ry} type {New..Int} refrIndex CompName {scaling proc} amb
/NewNodeComp {
    [ 5 1 roll trans {NewPlaneInt} 1 5 3 roll false NewOptexpComp
} bind def
%
% { x y } { rx ry } {scaling proc}
/NewCurvedInt {
    2 copy 5 3 roll exec 3 -1 roll exec VecAdd 5 -1 roll exec /Y ED /X ED
    exch exec 3 -1 roll exec 2 copy tx@Dict begin Pyth end /R ED /RY ED /RX ED
%    exch exec 2 copy add 0 lt { -1 } { 1 } ifelse /curv ED 3 -1 roll exec tx@Dict begin Pyth end /R ED
} bind def
%
% { x y } { dx dy } {scaling proc}
/NewPlaneInt {
    dup 3 -1 roll exec 3 -1 roll exec /DY ED /DX ED
    exch exec 3 -1 roll exec /Y ED /X ED
} bind def
%
% must be called within NewOptexpComp
% The plane has several attributes:
% {x y} are the coordinates of the node on the respective plane that is used
%       for unexpanded beams.
% {...} in case of a simple plane, this contains {dx dy} which is the relative
%       vector that defines the line representing the plane.
%       For curved surfaces, this procedure contains more values.
% type  Integer, characterizes if a surface is reflective or transmittent.
%       To avoid confusion you should use the parameters designed for that
%       (/refl and /trans)
% Name  String, Is the name of the new plane. It is expanded by an 'P@'
% {New..Int} Should contain the matching procedure for proper handling of the
%       variable procedure content {...}. Can be {NewPlaneInt} or {NewCurvedInt}
%
% { x y } {dx dy | rx ry} mode CompName Name {New..Int} {scaling proc}
/NewCompInt {
  /scl ED
  /next ED
  dup (P@) exch strcat cvn
  5 dict dup 			% { x y } {...} mode CompName Name /P@Name dict dict
  3 1 roll def 			% { x y } {...} mode CompName Name dict /P@Name dict def
  begin 			% { x y } {...} mode CompName Name dict begin
    3 -1 roll			% { x y } {...} CompName Name mode
    /mode ED                    % plane mode, 0: reflective, 1: transmittive
    4 -1 roll dup 5 -1 roll     % CompName Name { x y } { x y } {...}
    {scl} next
  end
  3 1 roll strcat exch exec scl ToVec exch @NewNode % store a new node /N@NameX, with X=1..N
  % this node always represents the intersection of an untilted and unshifted incoming beam
  % on the optical axis with the respective interface
} bind def
/refl 0 def /trans 1 def
/desc 0 def /asc 1 def /amb 2 def
%
% { x y } NodeName
/@NewNode {
    tx@NodeDict begin (N@) exch strcat cvn false exch 10 {InitPnode } NewNode end
} bind def
%
% About the design:
% NewOptexpComp creates a new dictionary that contains everything needed
% for an optical component. It contains the following variables:
% /n             -> refractive index (is usually 1)
% /CompMtrx      -> current matrix to store the planes correctly
% /name          -> name of the component
% /N             -> number of planes
% /P@1 ... /P@N  -> planes used for the 'ray tracing'
%
% [ { x y } { dx dy | rx ry} type {New..Int} refrIndex CompName {scaling proc} amb
/NewOptexpComp {
  3 1 roll /sc ED 
  dup cvn
  gsave
  10 dict dup 3 1 roll def begin
  /name ED
  /ambiguous ED
  tx@Dict begin
    STV {CP T} stopped pop % set scaling for all planes
  end
  /CompMtrx CM def
  grestore
  % count the planes and save their number
  counttomark dup 4 idiv dup /N ED 4 mul eq { 1 } if /n ED
  1 N eq {% only a single plane
      ambiguous { 4 copy name (C) 3 -1 roll {sc} NewCompInt } if
      4 copy name (1) 3 -1 roll {sc} NewCompInt
      name (N) 3 -1 roll {sc} NewCompInt
  }{
      ambiguous {
	  name (C) 3 -1 roll {sc} NewCompInt
	  /N N 1 sub def
      } if
      N -1 1 { %
	  dup N eq { pop (N) }{3 string cvs} ifelse
	  exch name 3 1 roll {sc} NewCompInt
      } for
  } ifelse
  end
  pop
} bind def
%
% PlaneNumber CompName -> PlaneVec
/GetPlaneVec {
    cvn load begin
%	dup N eq {
%	    pop (N)
%	} {
%	    3 string cvs
%	} ifelse
	PlaneName cvn load begin
	    currentdict /RX known {
		RX RY CompMtrx dtransform CM idtransform
		neg exch
	    } {
		DX DY CompMtrx dtransform CM idtransform
	    } ifelse
	end
    end
} bind def
%
% PlaneNumber CompName -> NodeCenter
% or
% {Plane} -> NodeCenter
/GetPlaneCenter {
    dup type /stringtype eq not {
	dup xcheck not {% ambiguous
	    0 get (C) exch
	} {
	    exec pop pop pop
	} ifelse
    } if
    cvn load begin
%	dup dup N eq {
%	    pop (N)
%	} {
%	    3 string cvs
%	} ifelse (N@)
%	name strcat exch strcat
%	cvn dup tx@NodeDict exch known {
%	    tx@NodeDict begin load GetCenter end
%	    3 -1 roll pop
%	} {
%	    pop
	    PlaneName cvn load begin
		currentdict /RX known {
		    X RX sub Y RY sub
		} {
		    X Y
		} ifelse
		CompMtrx transform CM itransform
	    end
%	} ifelse
    end
} bind def
%
% InVec is relative to the connection between first and second components
% transform to absolute coordinates
% Plane2 Plane1 {InVec} -> {InVec'}
/TransformInVec {
    3 1 roll % {InVec} P2 P1
    GetPlaneCenter 4 2 roll % X1 Y1 {InVec} Plane2
    GetPlaneCenter 5 -2 roll % {InVec} X2 Y2 X1 Y1
    @ABVect % {InVec} dX dY
    3 -1 roll exec 2 copy 6 2 roll % Xi Yi dX dY Xi Yi 
    0 eq exch 0 eq and not {% invec != (0,0)
	exch atan matrix rotate dtransform
    } {
	4 2 roll pop pop
    } ifelse
    ToVec
} bind def
%
% startpos is relative to the connection between first and second components
% transform to absolute coordinates and shift by first plane center
% Plane2 Plane1 {StartPos} -> {StartPos'+Plane1Center}
/TransformStartPos {
    exec 2 copy 6 2 roll 0 eq exch 0 eq and not  % SPx SPy P2 P1 neq00
    3 1 roll GetPlaneCenter 4 2 roll % SPx SPy X1 Y1 neq00 P2
    GetPlaneCenter 5 2 roll % SPx SPy X2 Y2 X1 Y1 neq00
    {% SP != (0,0)    SPx SPy X2 Y2 X1 Y1
	2 copy 8 2 roll % X1 Y1 SPx SPy X2 Y2 X1 Y1
	@ABVect	exch atan matrix rotate dtransform
	VecAdd
    } {
	6 2 roll pop pop pop pop
    } ifelse
    ToVec
} bind def
%
% X Y CompName -> PlaneNumber
/GetNearestPlane {
    3 copy 1 exch GetPlaneCenter @ABDist /dist ED /nearestPlane 1 def
    % X Y CompName
    dup cvn load /N get 2 1 3 -1 roll {
	% iterate through plane 2 to plane N of CompName 
	4 copy exch GetPlaneCenter @ABDist dup dist lt {
	    /dist ED /nearestPlane ED
	} {
	    pop pop
	} ifelse
    } for
    pop pop pop nearestPlane
} bind def
%
% Components which do not have an unambiguous behaviour (beamslitter, can
% transmit and reflect) like lenses (transmission only) or mirrors (reflection
% only), must be evaluated to see which mode should be used.  Argument is
% [(name) draw], draw is a boolean which is true if the inner beams should be
% drawn.
/PushAmbCompPlanesOnStack {
%    (PushAmpCompPlanesOnStack) ==
%    counttomark /t ED t copy t{==} repeat
%    (stack dumped) ==
    currentdict /outToPlane undef
    PN PlaneNum eq not {
	% not the last plane, there should be another one on the stack
	exch dup 3 1 roll % plane ambcomp plane
	dup xcheck not {
	    % the next component is also an ambcomp, use its center point as
	    % reference
	    0 get (C) exch
	} {
	    % otherwise use the plane node
	    exec pop pop pop
	} ifelse
	[ 3 1 roll ] cvx /outToPlane ED
	% outToPlane is {(PN) (compName)}
    } if
    % the old plane number, without counting the additional planes of the
    % current ambcomp
    /PlaneNumTmp PlaneNum def
    aload pop /draw ED /name ED
    name cvn load /N get /N ED
    currentdict /Curr known {
	/CurrTmp /Curr load def
	/CurrVecTmp /CurrVec load def
    } {
	/CurrTmp /CurrLow load def
	/CurrVecTmp /CurrVecLow load def
    } ifelse
    % CurrTmp is the current point of the beam on the previous plane, CurrVecTmp
    % its outgoing vector.
    1 N eq {
	% only a single interface
	[ (C) name 1 
	PN 1 eq PN PlaneNum eq or {
	    % its the first or last comp
	    trans
	} {
	    % somewhere in the middle, check the mode (trans or refl)
	    CurrVecTmp (C) name GetPlaneVec NormalVec outToPlane GetPlaneCenter (C) name GetPlaneCenter @ABVect SProd
	    0 lt { trans } { refl } ifelse % mode
	} ifelse
	true ] cvx
    } {
	% three interfaces
	PN 1 eq {
	    % first component
	    [ (C) name
	      nforce 0 eq { name cvn load /n get } { nforce } ifelse
	      trans draw ] cvx
	      % now check which is the outgoing plane
	      name /outToPlane load GetNextPlane
	      [ exch name 1 trans draw ] cvx exch
	      /PlaneNumTmp PlaneNumTmp 1 add def
	} {
	    CurrTmp name GetNearestPlane /nextPlane ED
	    %
	    % check if mode is trans or refl
	    CurrVecTmp nextPlane name GetPlaneVec NormalVec
	    (C) name GetPlaneCenter nextPlane name GetPlaneCenter @ABVect 2 copy 6 2 roll SProd 
	    0 lt { trans }{ refl } ifelse
	    3 1 roll ToVec /CurrVecTmp ED
	    [ nextPlane name
	    connectPlaneNodes {
		1
	    }{
		nforce 0 eq { name cvn load /n get } { nforce } ifelse
	    } ifelse
	    5 -1 roll true ] cvx % always draw to first interface
	    PN PlaneNum eq {
		% its the last comp, just put the center plane on the stack
		[ (C) name
		  nforce 0 eq { name cvn load /n get } { nforce } ifelse
		  trans draw ] cvx exch
		  /PlaneNumTmp PlaneNumTmp 1 add def
	    } {
		% check the mode
		[ (C) name
		connectPlaneNodes {
		    1
		} {
		    nforce 0 eq { name cvn load /n get } { nforce } ifelse
		} ifelse
		CurrVecTmp (C) name GetPlaneVec NormalVec outToPlane GetPlaneCenter (C) name GetPlaneCenter @ABVect SProd
		0 lt { trans } { refl } ifelse % mode
		draw ] cvx exch
		% now check which is the outgoing plane
		name /outToPlane load GetNextPlane
		[ exch name 1 trans draw ] cvx 3 1 roll
		/PlaneNumTmp PlaneNumTmp 2 add def
	    } ifelse
	} ifelse
    } ifelse
%    (-----------------------------------------------)==
    /PlaneNum PlaneNumTmp def
%    counttomark /t ED t copy t{==} repeat
} bind def
% 
% (CompName) {outToPlane} -> PlaneNumber
/GetNextPlane {
    2 copy (C) 3 -1 roll % (CompName) {outToPlane} {outToPlane} (C) (CompName)
    GetPlaneCenter 3 -1 roll exec GetPlaneCenter 4 2 roll 4 copy @ABVect /VecY ED /VecX ED @ABDist /centerDist ED
%    (centerDist) == centerDist ==
    /sprod 1 def
    % (CompName) {outToPlane}
    exch dup 3 1 roll cvn load /N get 1 1 3 -1 roll {
	% iterate through all planes of CompName
	% (CompName) {outToPlane} n
	3 copy 3 -1 roll 2 copy% (CompName) {outToPlane} n {outToPlane} n (CompName) n (CompName)
	%/t 8 def t copy t{==}repeat
	GetPlaneVec VecX VecY 4 2 roll NormalVec VecX VecY SProd dup sprod lt 
	5 2 roll % sprod bool {outToPlane} n (CompName)
	GetPlaneCenter 3 -1 roll exec GetPlaneCenter @ABDist centerDist lt and
	{
	    /sprod ED /nextPlane ED
	} {
	    pop pop
	} ifelse
    } for
    pop pop nextPlane
} bind def
%
% [ CompN ... Comp1 {options} {start point} {input vector}
% -> Yn Xn drawToN? ... Y1 X1 drawTo1? Y0 X0
/TraceBeam {%
    /InVec ED /StartPoint ED
    /oldbeaminsidelast currentdict /beaminsidelast known { beaminsidelast } { false } ifelse def
    % preset options
    /nmul 1 def
    /nadd 0 def
    /nforce 0 def
    % execute options
    exec
    /startInside startInside beaminsidefirst or def
    /stopInside stopInside beaminsidelast or def
    counttomark /N ED
    PrearrangePlanes
    PushAllPlanesOnStack
%    (planes on stack) == counttomark /t ED t copy t {==} repeat
    startvecabsolute not {
	2 copy /InVec load TransformInVec
    } {
	/InVec load
    } ifelse
    /CurrVec ED
    custombeam currentdict /lastBeamPoint known and {
	/lastBeamPoint load /Curr ED
    }{
	2 copy /StartPoint load  TransformStartPos /Curr ED
    } ifelse
%    (TraceBeam, transformations done) ==
%    counttomark /t ED t copy t {==} repeat
%    (=========================) ==
    counttomark /PlaneNum ED /n1 1 def % init the refractive index
    /PN 1 def
%    (start loop)==
    { % iterate over all planes
%	(PN) == PN ==
%	/Curr load ==
	dup xcheck not {% array, not executable
%	    (on stack) == counttomark /t ED t copy t {==} repeat	
	    PushAmbCompPlanesOnStack
%	    (completed planes on stack)==
%	    counttomark /t ED t copy t{==}repeat
%	    (PN) == PN ==
%	    PlaneNum ==
%	    (###############################)==
%	    (done)==
	} {
%	    (on stack) ==
%   	    counttomark /t ED t copy t{==}repeat
%	    (done)==
	} ifelse
	exec
	/draw ED
	/Mode ED
	3 1 roll % n PlaneNumber CompName
%        (load comp dict) ==
	cvn load begin % comp dict
%	    (comp dict) ==
	    PlaneName cvn load begin % plane dict
		X Y
%		PN 1 eq { (inplane center) == 2 copy == == } if
		CompMtrx transform CM itransform % n1 X Y
		2 copy ToVec 4 1 roll
%		PN 1 eq { (inplane center transformed) == 2 copy == == } if
		currentdict /RX known {
		    RX RY
		} {
		    DX DY %PN 1 eq { (inplane) == 2 copy == == } if
		} ifelse
		CompMtrx dtransform CM idtransform  
		Mode 6 -1 roll
		Curr CurrVec
		currentdict /RX known 
	    end
%	    (comp dict end)==
	end
%		counttomark /t ED t copy t{==}repeat
%	(done) ==
% {Xp Yp} Xp Yp dXp dYp trans|refl n2 X0 Y0 X_in Y_in curved?
	12 -1 roll /CurrCenter ED
	%PN 1 gt {
	%    CurrCenter CurrCenterTmp @ABVect NormalizeVec CurrVec VecAngle /relAngle ED
	%    (PN) == PN == relAngle ==
	%} if
	connectPlaneNodes {
	    PN 2 eq {% initialize relAngle, the angle between plane connection and input vector
		CurrCenter CurrCenterTmp @ABVect NormalizeVec CurrVec VecAngle /relAngle ED
	    } if
	    PN 3 ge {
%		(PN >= 3) ==
		ModeTmp trans eq {% previous plane was transmittive, recalculate the input vector
%		    (trans) ==
		    CurrCenter CurrCenterTmp @ABVect NormalizeVec
		    relAngle matrix rotate dtransform
		    %		counttomark /t ED t copy t{==}repeat
		    5 -2 roll pop pop 3 -1 roll
		} {% else, the previous plane was reflective, recalculate relAngle
		    CurrCenter CurrCenterTmp @ABVect NormalizeVec CurrVec VecAngle /relAngle ED
		} ifelse
	    } if
	} if
%	(before interface) == counttomark /t ED t copy t{==}repeat
	{ CurvedInterface }{ PlainInterface } ifelse
%	(*Interface done) == 
%	(after dict) ==
%	counttomark /t ED t copy t{==}repeat
	PN 1 eq {
	    pop pop
	    /draw beaminsidefirst oldbeaminsidelast xor def
	} {
	    ToVec /CurrVec ED
	} ifelse
	2 copy
	ToVec /Curr ED 
	draw
	counttomark 3 roll
        /CurrCenterTmp /CurrCenter load def
	/lastBeamPoint /Curr load def
	/lastVec /CurrVec load def
	/ModeTmp Mode def
	PN PlaneNum eq {
	    exit
	} {
	    CurrVec 0 eq exch 0 eq and {
		% last refraction was total internal reflection, exit!
		PlaneNum PN sub {pop} repeat
		exit
	    } if
	    /PN PN 1 add def
	} ifelse
%	counttomark /t ED t copy t{==}repeat
%	(---)==
    } loop
    currentdict /CurrVec undef
    currentdict /Curr undef
} bind def
%
% [ CompN ... Comp1 {options} {start point} {input vector}
/Drawbeam {
%    TraceBeam
    counttomark 3 eq {
	% first ray misses the next interface
	pop pop pop
    }{
	pop 5 copy 3 -1 roll pop ArrowA pop pop pop pop % go to Startpoint
	counttomark 3 idiv -1 2 {
	    pop {
		lineto
	    }{
		moveto
	    }ifelse
	} for
	{CP 4 2 roll ArrowB lineto pop pop } {moveto} ifelse
	pop % remove [
    } ifelse
} bind def
/sign {
    0 ge { 1 } { -1 } ifelse
} bind def
% Stroke an extendend beam. Only rearranges the input parameters and calls Drawbeam twice, for the upper
% and lower beam.
% [ CompN ... Comp1 {options} {start point up} {input vector up} {start point low} {input vector low}
/TraceExtendedBeam {
    % correct rotation of input vectors
%    5 -1 roll dup 6 1 roll exec % execute options
%    dup exec 5 -1 roll dup 6 1 roll exec % lowx lowy upx upy
%    4 -1 roll mul 3 1 roll mul sub sign beamdiv sign eq {
%	(----------------------------------------------------------not eq) ==
%	exec beamdiv 2 mul matrix rotate dup 4 1 roll itransform ToVec exch
%	4 -1 roll exec 3 -1 roll transform ToVec 3 1 roll
%    } {(---------ka-------------------------------------- equal sign) == }ifelse
    5 -1 roll dup 6 1 roll 3 1 roll % {opt} {sup} {inup} {opt} {slow} {inlow}
    counttomark 6 sub /numComp ED
    numComp 7 add 6 roll numComp 1 add copy % {opt} {sup} {inup} {opt} {slow} {inlow} [ CompN .. Comp1 [ CompN .. Comp1
    numComp 1 add 2 mul 6 add numComp 1 add roll % [ CompN .. Comp1 {opt} {sup} {inup} {opt} {slow} {inlow} [ CompN .. Comp1
    numComp 1 add 3 add -3 roll % [ CompN .. Comp1 {opt} {sup} {inup} [ CompN .. Comp1 {opt} {slow} {inlow}
    currentdict /lastBeamPointLow known {
	/lastBeamPointLow load /lastBeamPoint ED
    } if
    TraceBeam
    /lastBeamPoint load /lastBeamPointLow ED
    /lastVec load /lastVecLow ED
    currentdict /lastBeamPoint undef
    currentdict /lastBeamPointUp known {
	/lastBeamPointUp load /lastBeamPoint ED
    } if
    counttomark 1 add dup numComp 4 add add exch roll
    TraceBeam
    /lastBeamPoint load /lastBeamPointUp ED
    /lastVec load /lastVecUp ED
    lastBeamPointUp lastBeamPointLow @ABVect lastVecUp lastVecLow 3 -1 roll add 3 1 roll add exch
    4 -1 roll mul 3 1 roll mul sub 0 gt {
	% swap upper and lower beam points for next beam
	/lastBeamPointUp load /lastBeamPointLow load /lastBeamPointUp ED /lastBeamPointLow ED
    } if
} bind def
% Fill an extended beam. This must have an own procedure, because all segments
% of the beam must be filled separately.
% 
% [ CompN ... Comp1 {options} {start point up} {input vector up} {start point low} {input vector low} 
/FillExtendedBeam {
    /InvecLow ED /StartLow ED /InvecUp ED /StartUp ED 
    % preset options
    currentdict /fillBeam known not { /fillBeam {gsave fill grestore} def } if
    /DrawnSegm 0 def
    /nmul 1 def
    /nadd 0 def
    /nforce 0 def
    % execute user options
    exec
    /startInside startInside beaminsidefirst or def
    /stopInside stopInside beaminsidelast or def
    PrearrangePlanes
    PushAllPlanesOnStack
    startvecabsolute not {
	2 copy /InvecLow load TransformInVec /CurrVecLow ED
	2 copy /InvecUp load TransformInVec /CurrVecUp ED
    } {
	/InvecLow load /CurrVecLow ED
	/InvecUp load /CurrVecUp ED
    } ifelse
%    (invec done)==
%    counttomark /t ED t copy t{==}repeat
    custombeam currentdict /lastBeamPointLow known currentdict /lastBeamPointUp known and and {
	/lastBeamPointLow load /CurrLow ED
	/lastBeamPointUp load /CurrUp ED
    } {
	2 copy /StartLow load TransformStartPos /CurrLow ED
	2 copy /StartUp load TransformStartPos /CurrUp ED
    } ifelse
%    (StartVecUp) == /CurrVecUp load ==
%    (CurrentPoint Up) == /CurrUp load ==
%    (StartVecLow) == /CurrVecLow load ==
%    (CurrentPoint Low) == /CurrLow load ==
%    () ==
%    (startpos done)==
    counttomark /PlaneNum ED /n1 1 def
    /CurrR false def
    /PN 1 def
    {
	dup xcheck not {% array, not executable
	    PushAmbCompPlanesOnStack
%	    (completed planes on stack)==
%	    counttomark /t ED t copy t{==}repeat
%	    (done)==
	} if
	exec
	/draw ED
	/Mode ED
	3 1 roll cvn load begin % comp dict
%	    (before pushing on stack) ==
%	    counttomark /t ED t copy t{==}repeat
	    PlaneName cvn load begin % plane dict
%		(PlaneDict) ==
		X Y CompMtrx transform CM itransform
		2 copy ToVec 4 1 roll
%		(2-------) ==
%		counttomark /t ED t copy t{==}repeat
		currentdict /RX known {
		    RX RY 
		} {
		    DX DY
		} ifelse
		CompMtrx dtransform CM idtransform 4 copy
		Mode 10 -1 roll % {X Y} X Y DX DY X Y DX DY mode n1
%		(3-------) ==
%		counttomark /t ED t copy t{==}repeat
		6 copy
		currentdict /RX known
	    end
	end
	/curved ED
	/oldn1 n1 def
	% {X Y} X Y DX DY X Y DX DY mode n1 X Y DX DY mode n1
%	(all on stack) == PN == counttomark /t ED t copy t{==}repeat
	17 -1 roll /CurrPCenter ED
	% new upper vector and intersection point
	CurrUp CurrVecUp %(CurrUp) == 4 copy == == == == (done)==
	connectPlaneNodes {
%	    (--------------------------------------------------connectPlaneNodes)==
	    PN 2 eq {% initialize relAngle, the angle between plane connection and input vector
%		(PN = 2) ==
		%counttomark /t ED t copy t{==}repeat
		CurrPCenter CurrPCenterTmp @ABVect NormalizeVec CurrVecUp VecAngle /relAngleUp ED
%		(relAngleUp) == relAngleUp ==
%		(done) ==
	    } if
	    PN 3 ge {
%		(PN >= 3) ==
		ModeTmp trans eq {% previous plane was transmittive, recalculate the input vector
%		    (trans) ==
%		    counttomark /t ED t copy t{==}repeat
%		    (relAngleUp) == relAngleUp ==
		    CurrPCenter CurrPCenterTmp @ABVect NormalizeVec %(connvec) == 2 copy == == (done)==
		    relAngleUp matrix rotate dtransform %(connvec transformed) == 2 copy == == (done)==
%		    counttomark /t ED t copy t{==}repeat
		    4 2 roll pop pop
%		    (done) ==
		} {% else, the previous plane was reflective, recalculate relAngle
		    CurrPCenter CurrPCenterTmp @ABVect NormalizeVec CurrVecUp VecAngle /relAngleUp ED
		} ifelse
	    } if
	} if
%	(after connectPlaneNodes) ==
%	counttomark /t ED t copy t{==}repeat
%	(################) ==
	2 copy ToVec /OldVecUp ED
	curved {
%	    (curved) ==
	    CurvedInterface
	} {
%	    (plain) == 
	    PlainInterface
	} ifelse
	%/CurrVecUp load /OldVecUp ED
	/CurrUp load /OldUp ED
	ToVec /CurrVecUp ED
	ToVec /CurrUp ED
%	(upper done)==
	/n1 oldn1 def
	% new lower vector and intersection point
	CurrLow CurrVecLow
	%
	connectPlaneNodes {
	    PN 2 eq {% initialize relAngle, the angle between plane connection and input vector
		CurrPCenter CurrPCenterTmp @ABVect NormalizeVec CurrVecLow VecAngle /relAngleLow ED
	    } if
	    PN 3 ge {
%		(PN >= 3) ==
		ModeTmp trans eq {% previous plane was transmittive, recalculate the input vector
%		    (trans) ==
		    CurrPCenter CurrPCenterTmp @ABVect NormalizeVec
		    relAngleLow matrix rotate dtransform
		    %		counttomark /t ED t copy t{==}repeat
		    4 2 roll pop pop
%		    (done) ==
		} {% else, the previous plane was reflective, recalculate relAngle
		    CurrPCenter CurrPCenterTmp @ABVect NormalizeVec CurrVecLow VecAngle /relAngleLow ED
		} ifelse
	    } if
	} if
	2 copy ToVec /OldVecLow ED
	curved {
	    CurvedInterface
	} {
	    PlainInterface
	} ifelse
%	(interface done)==
	%/CurrVecLow load /OldVecLow ED
	/CurrLow load /OldLow ED
	ToVec /CurrVecLow ED
	ToVec /CurrLow ED
%	(lower done)==
	/OldR CurrR def
	curved {
	    tx@Dict begin Pyth end /CurrR ED
	} {
	    pop pop /CurrR false def
	} ifelse
%	(radius done) ==
	% X Y still on stack
	OldR type /realtype eq {
	    /CurrCenter load /OldCenter ED
	} if
	curved {
	    ToVec /CurrCenter ED
	} {
	    pop pop
	    /CurrCenter false def
	} ifelse
%	(center done) ==
        PN 1 gt {
%	    gsave
	    draw {
		/DrawnSegm dup load 1 add def
%	    (draw) == 
		OldUp moveto CurrUp lineto
		curved {
		    CurrCenter CurrUp CurrLow TangentCrosspoint
		    CurrLow CurrR arct
		} {
		    CurrLow lineto
		} ifelse
		OldLow lineto
		OldR type /booleantype eq not {% previous interface was also curved
		    OldCenter OldLow OldUp TangentCrosspoint
		    OldUp OldR arct
		} {
		    OldUp lineto
		} ifelse
	    } if
%	(done) ==
	    Mode refl eq draw and
	    draw not DrawnSegm 0 gt and or {
		fillBeam newpath
		/DrawnSegm 0 def
	    } if
%	    grestore
	} {
%	    PN == 1
	    /CurrVecUp /OldVecUp load def
	    /CurrVecLow /OldVecLow load def
	} ifelse
	PN PlaneNum eq {
	    DrawnSegm 0 gt { fillBeam newpath } if
	    exit
	} {
	    CurrVecUp 0 eq exch 0 eq and CurrVecLow 0 eq exch 0 eq and or {
		% last refraction was total internal reflection, exit!
		PlaneNum PN sub {pop} repeat
		DrawnSegm 0 gt { fillBeam newpath } if	
		exit
	    } if
	    /PN PN 1 add def
	} ifelse
%	(redef) ==
	/CurrPCenterTmp /CurrPCenter load def
%	(currpcentertmp done)==
	/ModeTmp Mode def
%	(mode done) ==
%	2 copy == ==
%	counttomark /t ED t copy t{==}repeat
%	(----------------------) ==
    } loop
    CurrUp CurrLow @ABVect CurrVecUp CurrVecLow 3 -1 roll add 3 1 roll add exch
    4 -1 roll mul 3 1 roll mul sub 0 gt {
	% swap upper and lower beam points for next beam
	/lastBeamPointUp /CurrLow load def
	/lastBeamPointLow /CurrUp load def
    } {
	/lastBeamPointLow /CurrLow load def
	/lastBeamPointUp /CurrUp load def
    } ifelse
%    (---------------------------------) ==
} bind def
% Check if 'compname' is ambiguous (i.e. a beamsplitter)
% (compname) -> bool
/isAmb { cvn load /ambiguous get } bind def
%
% [ CompN .. Comp1 PrearrangePlanes -> [ desc|asc CompN .. desc|asc Comp1 
/PrearrangePlanes {
%    counttomark /t ED t copy t {==} repeat
    counttomark /N ED
    /CompA ED dup /CompB ED
%    counttomark /t ED t copy t {==} repeat
%    (compa) == CompA == (compb)== CompB ==
    CompA isAmb {
%	(A amb)==
	amb dup CompA
    } {
	CompB isAmb {
%	    (B amb) ==
	    1 CompA GetPlaneCenter (C) CompB GetPlaneCenter @ABDist
	    (N) CompA GetPlaneCenter (C) CompB GetPlaneCenter @ABDist
	} {
%	    (none amb) ==
	    1 CompA GetPlaneCenter 1 CompB GetPlaneCenter (N) CompB GetPlaneCenter true OrderNodes exch pop
	    (N) CompA GetPlaneCenter 1 CompB GetPlaneCenter (N) CompB GetPlaneCenter true OrderNodes exch pop % dist1 distN
	} ifelse
	le { desc } { asc } ifelse dup CompA
%	(1212)==
    } ifelse
%    
    counttomark 2 roll
    2 1 N {
	/i ED exch /CompB ED %
	CompB isAmb not {
	    dup desc eq { 1 } { dup amb eq { (C) }{ (N) } ifelse } ifelse CompA GetPlaneCenter
	    1 CompB GetPlaneCenter
	    (N) CompB GetPlaneCenter false OrderNodes dup dup
	    % check if we have a NodeIfc
	    % dirA dirB dirB dirB
	    4 -1 roll CompA exch 5 -1 roll CompB exch
	    i 2 eq {% check also the first plane
		4 copy 4 2 roll AdjustRelRot
	    } if
	    AdjustRelRot
	} {
	    pop amb dup
	} ifelse
        CompB /CompA CompB def
	counttomark 2 roll
    } for pop
} bind def
%
% CompA desc|asc CompB desc|asc
/AdjustRelRot {
    exch dup cvn load /adjustRel known {
	dup dup 4 2 roll isAmb { exch pop (C)}{ desc eq {(N)}{1} ifelse } ifelse exch GetPlaneCenter 5 3 roll
	exch dup 3 1 roll isAmb { pop (C)}{ desc eq {1}{(N)} ifelse } ifelse exch GetPlaneCenter
	@ABVect exch atan exch
	cvn load begin
	    adjustRel {
		matrix rotate CompMtrx matrix concatmatrix /CompMtrx ED
		/adjustRel false def
	    } {
		pop
	    } ifelse
	end
    } {
	pop pop pop pop
    } ifelse
} bind def
%
% [ desc|asc CompN .. desc|asc Comp1 PushAllPlanesOnStack
% -> { PlaneNumber CompName n mode draw }
% n is the refractive index after the respective interface,
% but draw determines if the connection _to_ this interface
% is drawn
/PushAllPlanesOnStack {%
%    counttomark /t ED t copy t {==}repeat
    counttomark 2 div cvi /numComp ED
    1 1 numComp {% iterate over all components
	/last false def
	/first false def
	dup 1 eq {
	    /first true def pop beaminsidefirst
	} {
	    numComp eq {
		beaminsidelast
		/last true def
	    } {
		beamInside
	    } ifelse
	} ifelse /drawInside ED
	load dup /ambiguous get {
%	    (amb) ==
	    /name get drawInside [ 3 1 roll ]
	    counttomark 1 roll pop
	} {
	    begin % comp dict
%		(comp dict) == name ==
		desc eq {
		    N N -1 1 1
		} {
		    1 1 1 N N
		} ifelse
		% start start inc stop stop
		first startInside not and {
		    % first comp and we do not start inside
		    5 -2 roll % inc stop stop start start
		    pop pop % inc stop stop
		    2 copy 5 2 roll
		} if
		5 1 roll % stop start start inc stop
		{% iterate over all planes
		    % stop start i
%		    (i) == dup ==
		    3 1 roll 2 copy 5 -1 roll % stop start stop start i
		    dup 3 1 roll % stop start stop i start i
		    eq first not and { % the first plane
			true    % always draw the line to the first plane of a component
		    } {
			drawInside % the other beams depend on some options
		    } ifelse % on stack: stop i draw?
		    exch dup 4 -1 roll eq connectPlaneNodes or {% draw i i stop
			1 % after the last component plane we have always air
		    }{ % otherwise the respective refractive index of the component
			nforce 0 eq { n } {nforce} ifelse
		    }ifelse % draw i refrIndex
		    exch dup N eq {
			pop (N)
		    } {
			3 string cvs
		    } ifelse exch
		    3 1 roll name % refrIndex draw (i) name
		    4 1 roll % name refrIndex draw (i)
%		    (add mode)==
		    dup PlaneName load /mode get % name refrIndex draw i mode
%		    (added mode)==
		    3 1 roll 5 1 roll % i name refrIndex mode draw
		    [ 6 1 roll ] cvx counttomark 1 roll
		    last {
			custombeam stopInside not and
			custombeam not beaminsidelast not and or {
			    exit
			} if
		    } if
		} for pop pop
	    end
%	    (end comp dict)==
	} ifelse
%	(stack)==  counttomark /t ED t copy t {==}repeat
    } for
%    (Planes on stack:) ==
%    counttomark /t ED t copy t {==} repeat
%    (-------------------------------) ==
} bind def
% Construct the plane name from PlaneNum. This must be called within a dict of a
% optexpcomp, because the last node ends with (N) instead of the number.
% PlaneNum -> (P@PlaneNum)
/PlaneName {
    dup N eq {
	pop (N)
    } {
	3 string cvs
    } ifelse
    (P@) exch strcat
} bind def
% 
% A B1 BN dist? OrderNodes -> desc|asc distance?
/OrderNodes {% def
   /dist ED %cvn /BN ED cvn /B1 ED cvn /A ED
   6 -2 roll 2 copy 8 2 roll
   @ABDist 5 1 roll @ABDist 2 copy gt {
       pop asc exch
   } {
       exch pop desc exch
   } ifelse
   dist not {
       pop
   } if
} bind def
%
% construct a normal plane vector such that n·(-in) > 0
% X_in Y_in X_plane Y_plane NormalVec -> X_norm Y_norm
/NormalVec {
    neg exch 2 copy 6 2 roll SProd 0 gt {
	-1 mul exch -1 mul exch
    } if
    NormalizeVec
} bind def
%
% scalar product
% ax ay bx by SProd -> val
/SProd {
    3 -1 roll mul 3 1 roll mul add
} bind def
%
% angle between two vectors
% cos(alpha) = a·b/(|a||b|)
% ax ay bx by -> angle
/VecAngle {
    4 copy 4 copy SProd 5 1 roll tx@Dict begin Pyth 3 1 roll Pyth end mul div Acos
    5 2 roll mul 4 1 roll 3 -1 roll mul 3 -1 roll sub 0 le {-1}{1} ifelse mul
} bind def
% ax ay bx by VecAdd ax+bx ay+by
/VecAdd {
    3 -1 roll add 3 1 roll add exch
} bind def
/ToVec {
    [ 3 1 roll ] cvx
} bind def
% X Y NormalizeVec X' Y' (with X^2 + Y^2 = 1)
/NormalizeVec {
    2 copy
    tx@Dict begin
	Pyth
    end
    dup 3 1 roll div 3 1 roll div exch
} bind def
/@ABVect { tx@EcldDict begin ABVect end } bind def
/@ABDist { tx@EcldDict begin ABDist end } bind def
/@GetCenter { dup type /stringtype eq { cvn } if tx@NodeDict begin load GetCenter end } bind def
% see <http://en.wikipedia.org/wiki/Snell%27s_law#Vector_form>
% X_in Y_in X_norm Y_norm n1 n2 RefractVec -> X_out Y_out
/RefractVec {
    div /n ED 4 2 roll NormalizeVec /Yin ED /Xin ED /Ynorm ED /Xnorm ED
    n 1 eq {
%	(n = 1) ==
	Xin Yin
    }{
%	(n = ) == n ==
%	(Xin) == Xin  == (Yin) == Yin ==
%	(Xnorm) == Xnorm == (Ynorm) == Ynorm ==
	/costheta1 Xnorm Ynorm Xin neg Yin neg SProd def
%	(costheta1) == costheta1 ==
	1 n dup mul 1 costheta1 dup mul sub mul sub
	dup 0 lt {%
	    % would be total internal reflection, stop
	    pop 0 0
	} {
	    sqrt /costheta2 ED
	    n Xin mul n Yin mul n costheta1 mul costheta2 sub dup Xnorm mul exch Ynorm mul VecAdd
	} ifelse
    } ifelse
} bind def

% X_in Y_in X_norm Y_norm ReflectVec -> X_out Y_out
/ReflectVec {
    /Ynorm ED /Xnorm ED NormalizeVec /Yin ED /Xin ED
    /costheta1 Xnorm Ynorm Xin neg Yin neg SProd def
    Xin Yin 2 costheta1 mul dup Xnorm mul exch Ynorm mul VecAdd
} bind def

% X_p Y_p X_r Y_r trans|refl n2 X0 Y0 X_in Y_in CurvedInterface -> X' Y' X_out Y_out
/CurvedInterface {
    /Yin ED /Xin ED /Y0 ED /X0 ED /n2 ED /mode ED
    2 copy /Yr ED /Xr ED 
    tx@Dict begin Pyth end /radius ED /Yp ED /Xp ED
    /X0n X0 Xp sub def /Y0n Y0 Yp sub def
    n2 1 gt { /n2 n2 nmul mul nadd add def } if
    tx@EcldDict begin
	X0n Y0n 2 copy 2 copy Xin 3 -1 roll add Yin 3 -1 roll add
	2 copy 6 2 roll EqDr radius InterLineCircle
    end
    4 copy
    0 eq 3 {exch 0 eq and} repeat {% all coordinates are zero, missed circle, stop
%	(stop in curvedinterface) ==
	PlaneNum PN sub 4 add {pop} repeat
	exit
    } if
    4 copy
    % which point to take? 
    Xr neg Yr neg 2 copy
    8 -2 roll @ABDist %dist from first point
    5 1 roll @ABDist % dist1 dist2
    gt {% take second point
	4 2 roll
    } if pop pop
    Xp Yp VecAdd
    2 copy Xp Yp 4 2 roll @ABVect exch neg Xin Yin 4 2 roll NormalVec Xin Yin 4 2 roll
    % on stack: crossing point, in vector, and normal vector
    mode trans eq {
	n1 n2 RefractVec
    } {
	ReflectVec
    } ifelse /n1 n2 def
} bind def
%
% Xp Yp dXp dYp trans|refl n2 X0 Y0 X_in Y_in PlainInterface -> X' Y' X_out Y_out
/PlainInterface {%
%    (plain ifc) == 2 copy ToVec ==
    /Yin ED /Xin ED /Y0 ED /X0 ED /n2 ED /mode ED /dYp ED /dXp ED /Yp ED /Xp ED
    n2 1 gt { /n2 n2 nmul mul nadd add def } if
    tx@EcldDict begin
	Xp Yp Xp dXp add Yp dYp add X0 Y0 X0 Xin add Y0 Yin add InterLines Xin Yin
	Xin Yin dXp dYp NormalVec
    end
    mode trans eq {
	n1 n2 RefractVec
    } {
	ReflectVec
    } ifelse /n1 n2 def
} bind def
%
% Xp Yp Xt1 Yt1 Xt2 Yt2
/TangentCrosspoint {
    4 copy 4 copy 14 -2 roll 2 copy% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 Xp Yp Xp Yp
    6 2 roll @ABVect neg exch% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xp Yp -(Yt2 -Yp) (Xt2-Xp)
    6 2 roll @ABVect neg exch% Xt1 Yt1 Xt2 Yt2 Xt1 Yt1 Xt2 Yt2 -(Yt2-Yp) (Xt2-Xp) -(Yt1-Yp) (Xt1-Xp)
    8 -2 roll VecAdd 10 2 roll % Xt1-(Yt1-Yp) Yt1+(Xt1-Xp) Xt1 Yt1 Xt2 Yt2 Xt2 Yt2 -(Yt2-Yp) (Xt2-Xp)
    VecAdd % Xt1-(Yt1-Yp) Yt1+(Xt1-Xp) Xt1 Yt1 Xt2 Yt2 Xt2-(Yt2-Yp) Yt2+(Xt2-Xp)
    tx@EcldDict begin InterLines end
} bind def
%
% CompA|NodeA CombB|NodeB -> Coordinates of nodeA or the node of CompA which is nearest to nodeB
/NearestNode {
    dup xcheck not { nametostring } if /CompB ED
    dup xcheck not {% CompA
	nametostring /CompA ED
	/CompB load dup xcheck not {% CompB
	    (N@) exch strcat (1) strcat @GetCenter ToVec
	} if /CompB ED
	(N@) CompA strcat
	1 {% name and counter on stack
	    2 copy dup % name cnt name cnt cnt
	    3 string cvs 3 -1 roll exch strcat dup % name cnt cnt (namecnt) (namecnt)
	    tx@NodeDict exch known {%
		@GetCenter
		CompB @ABDist
		% cnt cnt dist
		exch 1 eq {% init /dist
		    /dist ED
		    dup /planeNum ED
		} {
		    dup dist lt {
			/dist ED
			dup /planeNum ED
		    } {
			pop
		    } ifelse
		} ifelse
		1 add % increment counter
	    } {
		pop pop pop dup (N) strcat
		@GetCenter
		CompB @ABDist
		dup dist lt {
		    /dist ED
		    /planeNum (N) def
		} {
		    pop
		} ifelse
		exit
	    } ifelse
	} loop
	planeNum 3 string cvs strcat @GetCenter
    } {% else, it is a node and we already have the appropriate coordinates on the stack
	exec
    } ifelse
} bind def

% Calculate start angle of pccurve from CompA to CompB
% CompA|nodeA CompB|nodeB -> angleA
/RelFiberAngle {%
    dup xcheck not { nametostring } if /CompB ED
    dup xcheck not { nametostring } if /CompA ED
    @ABVect % vector from NodeA to NodeB
    /CompA load xcheck {% nodeA
	/CompB load xcheck {% nodeB
	    exch atan
	} {% compB
	    (N@) CompB strcat dup (A) strcat exch (B) strcat
	    @GetCenter 3 -1 roll @GetCenter @ABVect 2 copy exch atan
	    5 1 roll SProd 0 lt { 180 add } if
	} ifelse
    } {% CompA
	(N@) CompA strcat dup (A) strcat exch (B) strcat
	@GetCenter 3 -1 roll @GetCenter @ABVect 2 copy exch atan
	5 1 roll SProd 0 lt { 180 add } if
    } ifelse
} bind def

/restoreBeamPoints {
    tx@OptexpDict dup /TmpLastBeamPointLow known { 
        /lastBeamPointLow /TmpLastBeamPointLow load def 
        /TmpLastBeamPointLow undef 
    } { 
        /lastBeamPointLow undef 
    } ifelse
    tx@OptexpDict dup /TmpLastBeamPointUp known {
        /lastBeamPointUp /TmpLastBeamPointUp load def 
        /TmpLastBeamPointUp undef 
    } { 
        /lastBeamPointUp undef 
    } ifelse
} bind def

% rearrange points of single beam
% [ A [ B -> [ B A
/rearrangeSingleBeamPoints {
    counttomark dup 2 add -1 roll pop % [ A B cnt
    dup counttomark 2 sub eq not { % [ A B cnt cnt!=counttomark
	% not the first beam
	4 1 roll pop pop pop 3 sub % [ A B cnt-3
    } if
    counttomark 1 sub exch roll
} bind def
% rearrange points of extended beam
%[ A [ B [ C [ D -> [ C A [ D B
/rearrangeExtBeamPoints {
    counttomark 1 add -1 roll pop % [ A [ B [ C D
    counttomark /t ED t 1 add -1 roll pop % [ A [ B C D
    counttomark t eq {
	% B is empty, first beam
	counttomark 1 add 1 [ 3 1 roll roll
	% [ C [ D
    } {
	counttomark 1 add -1 roll pop % [ A B C D
	counttomark t sub /@rest ED
	% check if first point of C/D is the same as last point of A/B
	% due to symmetry, need to check only D and B
	t @rest 2 idiv add -3 roll 6 copy pop 3 -1 roll pop
	3 -1 roll sub abs 1e-5 lt 3 1 roll sub abs 1e-5 lt and { % same points
	    t @rest 2 idiv add 3 roll	
	    pop pop pop t 2 idiv -3 roll pop pop pop
	    /t t 6 sub def
	} {
	    t @rest 2 idiv add 3 roll
	} ifelse
	t t 2 idiv roll % [ A B D C
	counttomark t 2 idiv roll % [ C A B D
	counttomark 2 idiv t 2 idiv roll % [ C A D B
	counttomark 2 idiv 1 add 1 [ 3 1 roll roll
    } ifelse
} bind def
end % tx@OptexpDict
