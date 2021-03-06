%%% This file is part of beerenthusiasts.
%%% 
%%% beerenthusiasts is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU Affero General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%% 
%%% beerenthusiasts is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU Affero General Public License for more details.
%%% 
%%% You should have received a copy of the GNU Affero General Public License
%%% along with beerenthusiasts.  If not, see <http://www.gnu.org/licenses/>.


-module (web_your_page).
-include ("wf.inc").
-compile(export_all).

main() ->

  case wf:user() of
        undefined ->
            wf:redirect("register"),
            Header = "";
        _ -> Header = "./wwwroot/user_template.html"
    end,
  #template { file=Header }.
  
title() -> "Beer Enthusiasts".

body () ->    
    Username = wf:user (),
    
    {ok, Results, _} = rfc4627:decode(couchdb_utils:doc_get_all (Username)),
    %io:format ("~w~n", [Results]),
    case Results of
        {obj,[{"total_rows",_TotalRows},
              {"offset", _Offset},
              {"rows",
               Recipes}]} ->
            Links = create_links (Recipes);
        {obj,[{"total_rows",_TotalRows},
              {"rows",
               Recipes}]} ->
            Links = create_links (Recipes)
    end,
    io:format ("~w~n", [Links]),
     
   [ 
     #link {text="Create Recipe", url="edit_recipe"},
     #br{},
     "Your Recipes:",
     #br{},
     #gravatar{email=db_backend:get_email_address(Username)},
     #flash { id=flash },
     #panel { id=test }
   ].
				      
event (_) ->
    ok.
 
create_links (Recipes) ->
    [wf:insert_bottom(test, [ID, " ", #link { text="[view]", url="view_doc?user="++ wf:user() ++"&doc_id="++ID}, #link { text="[edit]", url="edit_recipe?name="++ID}, #br{}]) 
     || {obj, [{"id", ID},
               {"key", Key},
               {"value", {obj,[{"rev", Rev}]}}]} <- Recipes].                         

