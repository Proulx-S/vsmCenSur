function resp = smrRoi(smr,ind)
resp       = [];
resp.vec   = cat(3,smr(ind).vec);
resp.t     = cat(3,smr(ind).x);
if any(any(diff(resp.t,[],3),3),2); error('time vector mismatch'); end
resp.t     = resp.t(:,:,1)';
resp.label = cat(3,smr(ind).label);
if any(1~=[length(unique(resp.label(:,1,:))) length(unique(resp.label(:,2,:)))]); error('label length mismatch'); end
resp.label = resp.label(:,:,1);

resp.vecAv  = mean(resp.vec,3,"omitnan");
resp.vecN   = sum(~isnan(resp.vec),3);
resp.vecErr = std(resp.vec,[],3,"omitnan")./sqrt(resp.vecN);




