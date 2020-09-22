function Mf = fillmiss(M)

% FILLMISS Interpolation values in a matrix.
% ALI MEHMANI
% am4515@columbia.edu
 % Handle input .............................................
 if nargin==0, help fillmiss, return, end

 % If no missing values, output=input, quick exit.
 % If all values are missing, give up  (output=input)
 % and prevent endless recursion ....................
if all(all(isnan(M)))|~any(any(isnan(M)))
   Mf = M;
return
end

 % Interpolation coefficients .......................
 % [left right left-left left-right right-right]
coef =  [eps eps 1/2 4/3 1/2];

 % Sizes ...................
n_miss = length(find(isnan(M)));
szM = size(M);
szMf2 = szM(2)+4;
is_vec = szM==1;

 % Auxillary ...............
v4 = -1:2;
o4 = ones(1,4);
o5 = ones(5,1);
o2 = ones(2,1);
omiss = ones(n_miss,1);
wsum = zeros(n_miss,2);
a = wsum;

 % Interpolate from both rows and columns, if possible
for jj = find(~is_vec)

  bM = zeros(2,szM(3-jj));   % Make margins
  Mf = M; if jj==2, Mf = M'; end
  Mf = [bM; isnan(Mf); bM];

  Mf = Mf(:);
  miss = find(Mf==1);       % Missing ##
  exis = find(~Mf);         % Available ##
  Mf = cumsum(~Mf);
  i_m = Mf(miss);

  Mf = M; if jj==2, Mf = M'; end
  Mf = [bM*nan; Mf; bM*nan];

  % Indices ................
  I = i_m(:,o4)+v4(omiss,:);
  I = reshape(exis(I),n_miss,4);    % Quartets of neib. pts for
                                    % each missing pts.

  % Make 5 estimates ...................................
  W = miss(:,o4)-I;
  A = zeros(n_miss,5);
  A(:,1:2) = reshape(Mf(I(:,2:3)),n_miss,2);
  A(:,3:5) = (W(:,1:3)-W(:,2:4));
  A(:,3:5) = reshape(Mf(I(:,2:4)),n_miss,3).*W(:,1:3);
  A(:,3:5) = A(:,3:5)-reshape(Mf(I(:,1:3)),n_miss,3).*W(:,2:4);
  A(:,3:5) = A(:,3:5)./(W(:,1:3)-W(:,2:4));

  % Calculate weights ......
  W = [abs(W(:,2:3)) abs(W(:,1:3))+abs(W(:,2:4))];
  W = (~isnan(A))./W;

  W = W.*coef(omiss,:);
  wsum(:,jj) = sum(W')';
  wsum(:,jj) = wsum(:,jj)-(wsum(:,jj)==0);
  W = W./wsum(:,jj*ones(1,5));
  i_m = find(isnan(A));
  A(i_m) = zeros(size(i_m));
  A = A.*W;
  a(:,jj) = A*o5;
end

 % Correspondence between row and column numbering .....
exis = ceil(miss/szMf2);
exis = exis+(miss-(exis-1)*szMf2)*szMf2;
[exis,i_m] = sort(exis);
wsum(:,1) = wsum(i_m,1);
a(i_m,1) = a(:,1);

 % Combine estimates from rows and columns .............
wsum = wsum+(wsum==-1);
exis = wsum*o2;
i_m = exis==0;
exis(i_m) = exis(i_m)+nan;
wsum = wsum./exis(:,o2);
exis = (a.*wsum)*o2;

 % Insert interpolated values into Mf ..................
Mf(miss) = exis;

  % Remove NaNs at the margins
Mf = Mf(3:szM(jj)+2,:);
if jj==2, Mf = Mf'; end

 % If there are still missing pts, repeat the procedure
if any(any(isnan(Mf))), Mf = fillmiss(Mf); end
