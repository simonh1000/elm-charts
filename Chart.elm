module Chart (chart, chartV, pie) where

import Html exposing (..)
import Html.Attributes exposing (class, id, style)

import List exposing (..)
import Dict exposing (Dict, update, get)

import Svg exposing (svg, circle)
import Svg.Attributes exposing (viewBox, r, cx, cy, width, height, stroke, strokeDashoffset, strokeDasharray )
-- import Json.Encode as Json exposing (string, int)
-- API

chart : List Float -> List String -> String -> Html
chart ds ls title =
    chartInit ds ls BarHorizontal
        |> chartTitle title
        |> normalise
        |> addValueToLabel
        |> updateStyles "elemStyles"
            [ ("font", "10px sans-serif")
            , ("text-align", "right")
            , ("color", "white")
            ]
        |> toHtml

chartV : List Float -> List String -> String -> Html
chartV ds ls title =
    chartInit ds ls BarVertical
        |> chartTitle title
        |> normalise
        -- |> addValueToLabel
        |> updateStyles "chartCtnrStyles"
            [ ("display", "flex")
            , ("align-items", "flex-end")
            , ("justify-content", "center")
            , ("height", "300px")
            ]
        |> updateStyles "elemStyles"
            [ ("width", "30px")
            ]
        |> updateStyles "labelCtnrStyles"
            [ ("display", "flex")
            , ("justify-content", "center")
            , ("height", "70px")
            ]
        |> updateStyles "labelStyles"
            [ ("width", "100px")
            , ("text-align", "right")
            , ("overflow", "hidden")
            , ("text-overflow", "ellipsis")
            ]
        |> toHtml

pie : List Float -> List String -> String -> Html
pie ds ls title =
    chartInit ds ls PieChart
        |> chartTitle title
        |> toPercent
        |> updateStyles "chartCtnrStyles"
            [ ("display", "flex") ]
        |> updateStyles "labelCtnrStyles"
            [ ("display", "flex") ]
        |> toHtml

-- MODEL

type ChartType = BarHorizontal | BarVertical | PieChart

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

chartInit : List Float -> List String -> ChartType -> Model
chartInit vs ls typ =
    { chartType = typ
    , items = initItems vs ls
    , title = ""
    , colours = []
    , styles =
        Dict.fromList
            [ ( "containerStyles"
              , [ ( "background-color", "#eee" )
                , ( "padding", "15px" )
                , ( "border", "2px solid #aaa" )
                , ( "display", "flex" )
                , ( "flex-direction", "column" )
                ]
              )
            , ( "chartCtnrStyles"
              , [ ( "background-color", "#fff" )
                , ( "padding", "20px 10px" )
                ]
              )
            , ( "elemStyles"
              , [ ("background-color","steelblue")
                , ("padding", "3px")
                , ("margin", "1px")
                ]
              )
            , ( "labelCtnrStyles", [] )
            , ( "labelStyles", [] )
            , ( "titleStyle", [("text-align", "center")] )
            ]
    }

-- UPDATE

chartTitle : String -> Model -> Model
chartTitle newTitle model =
     { model | title <- newTitle }

colours : List String -> Model -> Model
colours newColours model =
     { model | colours <- newColours }

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

-- adds the value of the item to the label
addValueToLabel : Model -> Model
addValueToLabel model =
    { model |
        items <- map (\item -> { item | label <- item.label ++ " " ++ toString item.value }) model.items
    }

-- UPDATE Styles

-- removes existing style setting (if any) and inserts new one
changeStyles : Style -> List Style -> List Style
changeStyles (attr, val) styles =
    (attr, val) :: (filter (\(t,_) -> t /= attr) styles)

updateStyles : String -> List Style -> Model -> Model
updateStyles selector lst model =
    { model | styles <-
        -- update selector (Maybe.map <| \curr -> foldl changeStyles curr lst) model.styles }
        update selector (Maybe.map <| flip (foldl changeStyles) lst) model.styles }


-- VIEW

toHtml : Model -> Html
toHtml model =
    -- let get' sel = Maybe.withDefault [] (get sel model.styles)
    -- in
    -- div [ style <| get' "containerStyles" ]
    --     [ h3 [ style <| get' "titleStyle" ] [ text model.title ]
    --     , div [ style <| get' "chartCtnrStyles" ] <|
            case model.chartType of
                BarHorizontal -> viewBarHorizontal model
                BarVertical -> viewBarVertical model
                PieChart -> viewPie model

viewBarHorizontal : Model -> Html
viewBarHorizontal model =
    let get' sel = Maybe.withDefault [] (get sel model.styles)
    in
    div [ style <| get' "containerStyles" ]
        [ h3 [ style <| get' "titleStyle" ] [ text model.title ]
        , div [ style <| get' "chartCtnrStyles" ] <|
            map
                (\{normValue, label} ->
                    div [ style <| ("width", toString normValue ++ "%") :: get' "elemStyles" ] [ text label ]
                )
                model.items
        ]

viewBarVertical : Model -> Html
viewBarVertical model =
    let get' sel = Maybe.withDefault [] (get sel model.styles)
    in
    div [ style <| get' "containerStyles" ]
        [ h3 [ style <| get' "titleStyle" ] [ text model.title ]
        , div [ style <| get' "chartCtnrStyles" ] <|
            map
                (\{normValue} -> div [ style <| ("height", toString normValue ++ "%") :: get' "elemStyles" ] [  ] )
                model.items
        , div [ style <| get' "labelCtnrStyles" ] <|
            indexedMap
                ( \idx item ->
                    div
                        [ style <| (labelTransform (length model.items) idx) :: get' "labelStyles" ]
                        [text (.label item)]
                ) model.items
        ]

labelTransform : Int -> Int -> Style
labelTransform lenData idx =
    let
        labelWidth = 60
        offset =
            case lenData % 2 == 0 of
                True ->  (lenData // 2 - idx - 1) * labelWidth + 20        -- 6 elements, 2&3 are the middle
                False -> (lenData // 2 - idx) * labelWidth - 10      -- 5 elements, 2 is the middle
    in ("transform", "translateX("++(toString offset)++"px) translateY(30px) rotate(-45deg)")

viewPie : Model -> Html
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
                , circleStyle
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
                    div [ style [ ("white-space", "nowrap") ] ]
                        [ span
                            [style
                                [ ("background-color", col)
                                , ("display", "inline-block")
                                , ("height", "20px")
                                , ("width", "20px")
                                , ("margin-right", "5px")
                                ]
                            ] [ text " " ]
                         , Html.text label
                         ]
                )
                items colours

        get' sel = Maybe.withDefault [] (get sel model.styles)
    in
    div [ style <| get' "containerStyles" ]
        [ h3 [ style <| get' "titleStyle" ] [ text model.title ]
        , div [ style <| get' "chartCtnrStyles" ] <|
            [ Svg.svg
                [ viewBox "0 0 32 32"
                , svgStyle
                ] elems
            , div
                [ style
                    [ ("display", "flex")
                    , ("flex-direction", "column")
                    , ("justify-content", "center")
                    , ("padding-left", "10px")
                    ]
                ]
                (legend model.items)
            ]
        ]

svgStyle =
    style
        [ ("width",  "100%")
        , ("height", "100%")
        , ("transform", "rotate(-90deg)")
        , ("background", "grey")
        , ("border-radius", "50%")
        ]
circleStyle =
    style
      [ ("fill-opacity", "0")
      , ("stroke-width", "32")
      ]

{-
containerStyles
    titleStyle
    chartCtnrStyles
        elemStyles
    labelCtnrStyles
        labelStyles
-}
