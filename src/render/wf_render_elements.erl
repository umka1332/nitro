-module (wf_render_elements).
-author('Maxim Sokhatsky').
-include_lib ("nitro/include/nitro.hrl").
-compile(export_all).

render_element(E) when is_list(E) -> E;
render_element(Element) when is_tuple(Element) ->
    Id = case element(#element.id,Element) of
        [] -> [];
        undefined -> undefined;
        L when is_list(L) -> L;
        Other -> nitro:to_list(Other) end,
    case element(#element.actions,Element) of [] -> skip; Actions -> nitro:wire(Actions) end,
    Tag = case element(#element.html_tag,Element) of [] -> nitro:to_binary(element(1, Element)); T -> T end,
    case element(#element.validation,Element) of
         [] -> skip;
         Code ->
         nitro:wire(nitro:f("{var name='~s'; qi(name)"
           ".addEventListener('validation',"
              "function(e) { if (!(~s)) e.preventDefault(); });"
              "qi(name).validation = true;}",[Id,Code])) end,
    case element(#element.module,Element) of
        [] -> default_render(Tag, Element);
        undefined -> default_render(Tag, Element);
        Module -> nitro:to_binary(Module:render_element(setelement(#element.id,Element,Id))) end;
render_element(Element) -> io:format("Unknown Element: ~p~n\r",[Element]).

default_render(Tag, Record) ->
    wf_tags:emit_tag(Tag, nitro:render(lists:flatten([element(#element.body,Record)])),
        lists:append([
           [{<<"id">>,              element(#element.id, Record)},
            {<<"class">>,           element(#element.class, Record)},
            {<<"style">>,           element(#element.style, Record)},
            {<<"title">>,           element(#element.title, Record)},
            {<<"accesskey">>,       element(#element.accesskey, Record)},
            {<<"contenteditable">>, element(#element.contenteditable, Record)},
            {<<"contextmenu">>,     element(#element.contextmenu, Record)},
            {<<"dir">>,             element(#element.dir, Record)},
            {<<"draggable">>,       element(#element.draggable, Record)},
            {<<"dropzone">>,        element(#element.dropzone, Record)},
            {<<"hidden">>,          element(#element.hidden, Record)},
            {<<"lang">>,            element(#element.lang, Record)},
            {<<"spellcheck">>,      element(#element.spellcheck, Record)},
            {<<"translate">>,       element(#element.translate, Record)},
            {<<"tabindex">>,        element(#element.tabindex, Record)},
            {<<"onmouseout">>,      element(#element.onmouseout, Record)},
            {<<"onmouseover">>,     element(#element.onmouseover, Record)},
            {<<"role">>,            element(#element.role, Record)}],
        element(#element.data_fields, Record),
        element(#element.aria_states, Record)])).