#!/usr/bin/lua

forwDeclPat = "^//{{" .. "{@@"
forwDeclEndPat = "^//}}" .. "}"

totalCount = 0
isInsideForwDecl = false

for i = 1, #arg do
   local filename = arg[i]
   for line in io.lines(filename) do
      if isInsideForwDecl then
         if string.match(line, forwDeclEndPat) then
            isInsideForwDecl = false
         end
      else
         if string.match(line, forwDeclPat) then
            isInsideForwDecl = true
         elseif not string.match(line, "^%s*$") and not string.match(line, "^%s*//")
           and not string.match(line, "^%s*/%*")  and not string.match(line, "^%s*%*")
         then
            totalCount = totalCount + 1
         end
      end
   end
end

print(totalCount)
