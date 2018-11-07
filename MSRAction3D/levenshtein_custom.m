function score = levenshtein_custom(s1, s2)
      score=0;
      s1new= s1;
      if(length(s1)>length(s2))
          s1new =s1(1:length(s2));
      end
      for i=1:length(s1new)
          if ~ismember(s1new(i),s2)
                  score= score+1;
          end
      end

  
%     result =0
%     if length(s1) < length(s2)
%         score = levenshtein_custom(s2, s1);
%     elseif isempty(s2)
%         score = length(s1);
%     else
%         while(i<length(s1)-1)
%             for (j=0:2:(length(s2)-1))
%                 if(s1(i:i+1) == s2(j:j+1))
%                     result= result+1
%                 end
%             end
%             i=i+2
%         end
end
