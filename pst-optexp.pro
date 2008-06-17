%
% PostScript prologue for pst-optexp.tex.
% version 0.1 2008-06-17 (cb)
% For distribution, see pstricks.tex.
%
/tx@OptexpDict 20 dict def
tx@OptexpDict begin
%
%
% expects: XB YB  XA YA XG YG
/calcNodes {% def
    /YG ED /XG ED
    /ay YG 3 -1 roll sub def
    /ax XG 3 -1 roll sub def
    /by exch YG sub def
    /bx exch XG sub def
    /a ax ay Pyth def
    /b bx by Pyth def
    /cx ax a div bx b div add def
    /cy ay a div by b div add def
    /c@tmp cx cy Pyth def
    /c ax bx add ay by add Pyth def
    %
    % if c=0, then set the coordinates of the vector manually
    % depending on the dotproduct (and thus, if 'a' and 'b'
    % are parallel or antiparallel
    c 0 eq
	{ax bx mul ay by mul add 0 gt
            % if dotprod > 0 then a and b are parallel
		{/cx ax def
              /cy ay def}
             % else a and b are antiparallel
             {/cx ay def
              /cy ax neg def} ifelse
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
	ax by mul ay bx mul sub 0 le
          {Y@A X@A 
           /X@A X@B def
           /Y@A Y@B def
           /X@B ED
           /Y@B ED}if
} bind def
%
% called with:  height R1
% leaves on stack: y |R1| alpha_bottom alpha_top R1
/leftConvex {% def
   /R1 ED /h ED
   /a1 R1 dup dup mul h dup mul sub sqrt sub def
   0 R1 abs
   R1 a1 sub neg dup
   h exch atan exch
   h neg exch atan
   /ArcL /arc load def
   R1
} bind def
%
% called with: height R1
% leaves on stack: y |R1| alpha_bottom alpha_top R1
/leftConcave {% def
   /R1 ED /h ED
   /a1 R1 abs dup dup mul h dup mul sub sqrt sub def
   0 R1 abs
   R1 neg a1 sub dup
   h exch atan exch
   h neg exch atan
   /ArcL /arcn load def
   /a1 0.5 a1 mul def
   R1
} bind def
%
% called with: height R2
% leaves on stack: y |R2| alpha_bottom alpha_top R2
/rightConvex {%def
   /R2 ED /h ED
   /a2 R2 abs dup dup mul h dup mul sub sqrt sub def
   0 R2 abs
   R2 a2 sub dup
   h neg exch atan exch
   h exch atan
   R2
   /ArcR /arc load def
} bind def
%
% called with: height R2
% leaves on stack: y |R2| alpha_bottom alpha_top R2
/rightConcave {%def
   /R2 ED /h ED
   /a2 R2 abs dup dup mul h dup mul sub sqrt sub def
   0 R2 abs
   R2 a2 add dup
   h neg exch atan exch
   h exch atan
   /ArcR /arcn load def
   /a2 0.5 a2 mul def
   R2
} bind def
%
end % tx@OptexpDict
