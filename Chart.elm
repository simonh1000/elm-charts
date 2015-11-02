module Chart (ChartType, hBar, vBar, pie, chartInit, title, colours, addValueToLabel, updateStyles) where
{-| This library supports three basic chart types. The horizontal bar chart is built with simple div elements(based on an ideas from the D3 blog); the vertical one uses a flexbox layout and some CSS transforms, while the Pie chart is based on [this post](http://www.smashingmagazine.com/2015/07/designing-simple-pie-charts-with-css/).

# Definition
@docs ChartType

# Prebuilt charts
@docs hBar, vBar, pie

# Customisers
@docs chartInit, title, colours, addValueToLabel, updateStyles

-}

import Html exposing (..)
import Html.Attributes exposing (style)

import List exposing (..)
import Dict exposing (Dict, update, get)

import Svg exposing (svg, circle)
import Svg.Attributes exposing (viewBox, r, cx, cy, width, height, stroke, strokeDashoffset, strokeDasharray, preserveAspectRatio)

-- MODEL
{-|
-}
type ChartType =
      BarHorizontal
    | BarVertical
    | Pie

type alias Item =
    { value : Float
    , normValue : Float
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
{-|

    hBar vals labels "My Chart"
        |> toHtml
-}
hBar : List Float -> List String -> String -> Html
hBar ds ls cTitle =
    chartInit ds ls BarHorizontal
        |> title cTitle
        |> normalise
        |> addValueToLabel
        |> updateStyles "chart-container"
            [ ( "display", "block" )
            ]
        |> updateStyles "chart-elements"
            [ ( "font", "10px sans-serif" )
            , ( "text-align", "right" )
            , ( "color", "white" )
            ]
        |> toHtml

{-|

    vBar vals labels "My Chart"
        |> toHtml
-}
vBar : List Float -> List String -> String -> Html
vBar ds ls cTitle =
    chartInit ds ls BarVertical
        |> title cTitle
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
            [ ( "width", "30px" )
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
        |> toHtml

{-|

    pie vals labels "My Chart"
        |> toHtml
-}
pie : List Float -> List String -> String -> Html
pie ds ls cTitle =
    chartInit ds ls Pie
        |> title cTitle
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
        |> toHtml

{-| chartInit creates the basic data model that can be fine-tuned by subsequent function applications. It takes a list of values, labels and the chart type. This must be called first.
-}
chartInit : List Float -> List String -> ChartType -> Model
chartInit vs ls typ =
    { chartType = typ
    , items = initItems vs ls
    , title = ""
    , colours = []
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
            , ( "chart-elements"
              , [ ( "background-color","steelblue" )
                , ( "padding", "3px" )
                , ( "margin", "1px" )
                ]
              )
            , ( "legend"
              , [ ( "display", "flex" ) ] )
            , ( "legend-labels", [] )
            ]
    }

-- UPDATE
{-| title adds a title to the model
-}
title : String -> Model -> Model
title newTitle model =
     { model | title <- newTitle }

{-| colours adds a list of colours ...
-}
colours : List String -> Model -> Model
colours newColours model =
     { model | colours <- newColours }

{-| adds the value of the item to the label
-}
addValueToLabel : Model -> Model
addValueToLabel model =
    { model |
        items <- map (\item -> { item | label <- item.label ++ " " ++ toString item.value }) model.items
    }

-- UPDATE normalise data
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

-- UPDATE Styles

-- removes existing style setting (if any) and inserts new one
changeStyles : Style -> List Style -> List Style
changeStyles (attr, val) styles =
    (attr, val) :: (filter (\(t,_) -> t /= attr) styles)

{-| Add custom styling to chart. updateStyles takes a list of styles and adds / replaces them to the existing base styles.
    container
        title
        chart-container
            {chart}
                chart-elements
            label/legend
                legend-labels

    updateStyles [()]
-}
updateStyles : String -> List Style -> Model -> Model
updateStyles selector lst model =
    { model | styles <-
        -- update selector (Maybe.map <| \curr -> foldl changeStyles curr lst) model.styles }
        update selector (Maybe.map <| flip (foldl changeStyles) lst) model.styles }


-- VIEW

{-| Called last, this causes the chart data to be rendered.
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
        elements =
            map
                (\{normValue, label} ->
                    div [ style <| ( "width", toString normValue ++ "%" ) :: get' "chart-elements" ] [ text label ]
                )
                model.items
    in
    [ div [ style <| get' "chart-container" ] <| elements ]

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
        colours = ["#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"]
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
                , if List.isEmpty cs then colours else cs
                , elem accOff (round normValue) c :: accElems
                )

        (_, _, elems) = foldl go (0, colours, []) model.items

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
                items colours

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
