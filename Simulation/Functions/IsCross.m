function flagCross = IsCross(lineSeg1, lineSeg2)
% Determine whether 2 linesegments cross each other or not.
%  lineSeg1 and lineSeg2 are both 2*2 matrix with their 2 rows vectors 
% corresponding to the coordinate of their 2 end points.
A=[0, 1;
  -1, 0];
sign1 = (lineSeg2(1,:) - lineSeg2(2,:)) * A * (lineSeg1(1,:) - lineSeg2(1,:))';
sign2 = (lineSeg2(1,:) - lineSeg2(2,:)) * A * (lineSeg1(2,:) - lineSeg2(1,:))';
sign3 = (lineSeg1(1,:) - lineSeg1(2,:)) * A * (lineSeg2(1,:) - lineSeg1(1,:))';
sign4 = (lineSeg1(1,:) - lineSeg1(2,:)) * A * (lineSeg2(2,:) - lineSeg1(1,:))';
flagCross = (sign1 * sign2 < 0 && sign3 * sign4 <0);
end

