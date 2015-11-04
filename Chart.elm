module Chart (hBar, vBar, pie, title, colours, colors, addValueToLabel, updateStyles, toHtml) where
{-| This library supports three basic chart types. The horizontal bar chart is built with simple div elements (based on an ideas from [D3]()); the vertical one uses a flexbox layout and some CSS transforms, while the Pie chart is based on [this post](http://www.smashingmagazine.com/2015/07/designing-simple-pie-charts-with-css/).

This module comprises tools to create and modify a model of the data, labels and styling, and then the function `toHtml` renders the model using one of the provided views. Three convenience functions are provided to accelerate modeling, but the defaults can be overriden.

# Chart constructors
@docs hBar, vBar, pie

# Customisers
@docs title, colours, colors, addValueToLabel, updateStyles

# Rendering
@docs toHtml
-}

import Html exposing (Html, h3, div, span, text)
import Html.Attributes exposing (style)

import List exposing (map, map2, length, filter, maximum, foldl, indexedMap)
import Dict exposing (Dict, update, get)

import Svg exposing (svg, circle)
import Svg.Attributes exposing (viewBox, r, cx, cy, width, height, stroke, strokeDashoffset, strokeDasharray, preserveAspectRatio)

-- MODEL

type ChartType =
      BarHorizontal
    | BarVertical
    | Pie

type alias Item =
    { value : Float
    , normValue: Float
    , label : String
    }
initItem v l =
    { value = v
    , normValue = 0
    , label = l
    }

type alias Items = List Item
initItems = map2 initItem

type alias Style = (String, String)

type alias Model =
    { chartType : ChartType
    , items : Items
    , title : String
    , colours : List String
    , styles: Dict String (List Style)
    }

-- API

{-| The horizontal bar chart results in a set of bars, one above the other, of lengths in proportion to the value. A label with the data value is printed in each bar.

    hBar vals labels
        |> title "My Chart
        |> toHtml
-}
hBar : List Float -> List String -> Model
hBar ds ls =
    chartInit ds ls BarHorizontal
        -- |> title cTitle
        |> normalise
        |> addValueToLabel
        |> updateStyles "chart-container"
            [ ( "display", "block" )
            ]
        |> updateStyles "chart-elements"
            [ ( "background-color","steelblue" )
            , ( "padding", "3px" )
            , ( "margin", "1px" )
            , ( "font", "10px sans-serif" )
            , ( "text-align", "right" )
            , ( "color", "white" )
            ]

{-| The vertical bar chart results in a set of bars of lengths in proportion to the value. A label is printed below each bar.

    vBar vals labels
        |> title "My Chart"
        |> toHtml
-}
vBar : List Float -> List String -> Model
vBar ds ls =
    chartInit ds ls BarVertical
        -- |> title cTitle
        |> normalise
        |> updateStyles "chart-container"
            [ ( "flex-direction", "column" )
            ]
        |> updateStyles "chart"
            [ ( "display", "flex" )
            , ( "justify-content", "center" )
            , ( "align-items", "flex-end" )
            , ( "height", "300px" )
            ]
        |> updateStyles "chart-elements"
            [ ( "background-color","steelblue" )
            , ( "padding", "3px" )
            , ( "margin", "1px" )
            , ( "width", "30px" )
            ]
        |> updateStyles "legend"
            [ ( "align-self", "center" )
            , ( "height", "70px" )
            ]
        |> updateStyles "legend-labels"
            [ ( "width", "100px" )
            , ( "text-align", "right" )
            , ( "overflow", "hidden" )
            , ( "white-space", "nowrap" )
            , ( "text-overflow", "ellipsis" )
            ]

{-| The pie chart results in a circle cut into coloured segments of size proportional to the data value.

    pie vals labels
        |> toHtml
-}
pie : List Float -> List String -> Model
pie ds ls =
    chartInit ds ls Pie
        -- |> title cTitle
        |> toPercent
        |> updateStyles "chart-container"
            [ ( "justify-content", "center" )
            ]
        |> updateStyles "chart"
            [ ( "height", "200px" )
            , ( "transform", "rotate(-90deg)" )
            , ( "background", "grey" )
            , ( "border-radius", "50%" )
            ]
        |> updateStyles "chart-elements"
            [ ( "fill-opacity", "0" )
            , ( "stroke-width", "32" )
            ]
        |> updateStyles "legend"
            [ ( "flex-direction", "column" )
            , ( "justify-content", "center" )
            , ( "padding-left", "10px" )
            ]
        |> updateStyles "legend-labels"
            [ ( "white-space", "nowrap" )
            ]

{-| chartInit creates the basic data model that can be fine-tuned by subsequent function applications. It takes a list of values, labels and the chart type. This must be called first.
-}
chartInit : List Float -> List String -> ChartType -> Model
chartInit vs ls typ =
    { chartType = typ
    , items = initItems vs ls
    , title = ""
    , colours = ["#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"]
    , styles =
        Dict.fromList
            [ ( "title", [( "text-align", "center" )] )
            , ( "container"
              , [ ( "background-color", "#eee" )
                , ( "padding", "15px" )
                , ( "border", "2px solid #aaa" )
                , ( "display", "flex" )
                , ( "flex-direction", "column" )
                ]
              )
            , ( "chart-container"
              , [ ( "display", "flex" )
                , ( "background-color", "#fff" )
                , ( "padding", "20px 10px" )
                ]
              )
            , ( "chart"
              , [ ( "display", "flex" ) ]
              )
            , ( "chart-elements", [] )
            , ( "legend"
              , [ ( "display", "flex" ) ] )
            , ( "legend-labels", [] )
            ]
    }

-- UPDATE

{-| title adds a title to the model.

    -- e.g. build a chart from scratch
    chartInit vs ls BarHorizontal
        |> title "This will be the title"
        |> toHtml
-}

title : String -> Model -> Model
title newTitle model =
     { model | title <- newTitle }

{-| colours replaces the default colours. Bar charts use just one colour, which will be the head of the list provided.

    vChart vs ls
        |> colours ["steelblue", "#96A65B", "#D9A679", "#593F27", "#A63D33"]    -- pie chart
        |> toHtml
-}
colours : List String -> Model -> Model
colours newColours model =
    case newColours of
        [] -> model
        (c :: cs) ->
            case model.chartType of
                Pie -> { model | colours <- (c :: cs) }
                otherwise ->
                    updateStyles "chart" [ ( "background-color", c ) ] model

{-| colors supports alternative spelling of colours
-}
colors : List String -> Model -> Model
colors = colours

{-| addValueToLabel adds the data value of each item to the data label. This is applied by default in hBar.

    vBar vs ls "Title"
        |> addValueToLabel
        |> toHtml
-}
addValueToLabel : Model -> Model
addValueToLabel model =
    { model |
        items <- map (\item -> { item | label <- item.label ++ " " ++ toString item.value }) model.items
    }

{-| updateStyles replaces styles for a specified part of the chart. Charts have the following div structure

    .container
        .title
        .chart-container
            .chart      (container for the bars or pie segments)
                .chart-elements
            .legend     (also for the label container in a vertical bar chart)
                .legend-labels

    vChart vs ls
        |> updateStyles "chart" [ ( "color", "black" ) ]
        |> toHtml
-}
updateStyles : String -> List Style -> Model -> Model
updateStyles selector lst model =
    { model | styles <-
        -- update selector (Maybe.map <| \curr -> foldl changeStyles curr lst) model.styles }
        update selector (Maybe.map <| flip (foldl changeStyles) lst) model.styles }


-- NOT exported

normalise : Model -> Model
normalise model =
    case maximum (map .value model.items) of
        Nothing -> model
        Just maxD ->
            { model |
                items <- map (\item -> { item | normValue <- item.value / maxD * 100 }) model.items
            }

toPercent : Model -> Model
toPercent model =
    let tot = List.sum (map .value model.items)
    in
        { model |
            items <- map (\item -> { item | normValue <- item.value / tot * 100 }) model.items
        }

-- removes existing style setting (if any) and inserts new one
changeStyles : Style -> List Style -> List Style
changeStyles (attr, val) styles =
    (attr, val) :: (filter (\(t,_) -> t /= attr) styles)


-- VIEW

{-| toHtml is called last, and causes the chart data to be rendered to html.

    hBar vs l
        |> toHtml
-}

toHtml : Model -> Html
toHtml model =
    let get' sel = Maybe.withDefault [] (get sel model.styles)
    in
    div [ style <| get' "container" ]
        [ h3 [ style <| get' "title" ] [ text model.title ]
        , div [ style <| get' "chart-container" ] <|
            -- chart-elements, axis, legend-labels,...
            case model.chartType of
                BarHorizontal -> viewBarHorizontal model
                BarVertical -> viewBarVertical model
                Pie -> viewPie model
        ]

viewBarHorizontal : Model -> List Html
viewBarHorizontal model =
    let
        get' sel = Maybe.withDefault [] (get sel model.styles)
        colour = Maybe.withDefault "steelblue" (List.head model.colours)
        elements =
            map
                (\{normValue, label} ->
                    div [ style <|
                            [ ( "width", toString normValue ++ "%" )
                            , ( "color", colour )
                            ] ++ get' "chart-elements"
                        ] [ text label ]
                )
                model.items
    in
    [ div
        [ style <| get' "chart-container" ]
        elements
    ]

-- V E R T I C A L
viewBarVertical : Model -> List Html
viewBarVertical model =
    let
        get' sel = Maybe.withDefault [] (get sel model.styles)

        elements =
            map
                (\{normValue} -> div [ style <| ( "height", toString normValue ++ "%" ) :: get' "chart-elements" ] [  ] )
                model.items

        rotateLabel : Int -> Int -> Style
        rotateLabel lenData idx =
            let
                labelWidth = 60
                offset =
                    case lenData % 2 == 0 of
                        True ->  (lenData // 2 - idx - 1) * labelWidth + 20        -- 6 chart-elements, 2&3 are the middle
                        False -> (lenData // 2 - idx) * labelWidth - 10      -- 5 chart-elements, 2 is the middle
            in ( "transform", "translateX( "++(toString offset)++"px) translateY(30px) rotate(-45deg)" )

        labels =
            indexedMap
                ( \idx item ->
                    div
                        [ style <| (rotateLabel (length model.items) idx) :: get' "legend-labels" ]
                        [ text (.label item) ]
                ) model.items
    in
    [ div [ style <| get' "chart" ] elements
    , div [ style <| get' "legend" ] labels
    ]

-- P I E   V I E W
viewPie : Model -> List Html
viewPie model =
    let
        elem off ang col =
            circle
                [ r "16"
                , cx "16"        -- translation x-axis
                , cy "16"
                , stroke col
                , strokeDashoffset (toString off)
                , strokeDasharray <| (toString ang) ++ " 100"
                , style <| get' "chart-elements"
                ] []
        go =
            \{normValue} (accOff, (c::cs), accElems) ->
                ( accOff - round normValue
                , if List.isEmpty cs then model.colours else cs
                , elem accOff (round normValue) c :: accElems
                )

        (_, _, elems) = foldl go (0, model.colours, []) model.items

        legend items =
            List.map2
                ( \{label} col ->
                    div [ style <| get' "legend-labels" ]
                        [ span
                            [style
                                [ ( "background-color", col)
                                , ( "display", "inline-block" )
                                , ( "height", "20px" )
                                , ( "width", "20px" )
                                , ( "margin-right", "5px" )
                                ]
                            ] [ text " " ]
                         , Html.text label
                         ]
                )
                items model.colours

        get' sel = Maybe.withDefault [] (get sel model.styles)
    in
        [ Svg.svg                       -- chart
            [ style (get' "chart" )
            , viewBox "0 0 32 32"
            , preserveAspectRatio "xMidYMid slice"
            ] elems
        , div                           -- legend
            [ style <| get' "legend" ]
            (legend model.items)
        ]
