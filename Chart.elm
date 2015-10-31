{-
containerStyles
    titleStyle
    chartCtnrStyles
        elemStyles
    labelCtnrStyles
        labelStyles
-}

module Chart (chart, chartV) where

import Html exposing (..)
import Html.Attributes exposing (class, id, style)

import List exposing (..)

-- API

chart : List Float -> List String -> String -> Html
chart ds ls title =
    chartInit ds ls BarHorizontal
        |> chartTitle title
        |> normalise
        |> addValueToLabel
        |> elemStyles [("background-color","steelblue")]
        |> toHtml

chartV : List Float -> List String -> String -> Html
chartV ds ls title =
    chartInit ds ls BarVertical
        |> chartTitle title
        |> normalise
        -- |> addValueToLabel
        |> containerStyles
            [ ("display", "flex")
            , ("flex-direction", "column")
            ]
        |> chartCtnrStyles
            [ ("display", "flex")
            , ("height", "300px")
            , ("align-items", "flex-end")
            , ("justify-content", "center")
            ]
        |> elemStyles
            [ ("background-color","red")
            , ("width", "30px")
            ]
        |> labelCtnrStyles
            [ ("display", "flex")
            , ("justify-content", "center")
            , ("height", "50px")
            ]
        |> labelStyles
            [ ("width", "80px")
            , ("text-align", "right")
            ]
        |> toHtml

-- MODEL

type ChartType = BarHorizontal | BarVertical | Pie

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
    , containerStyles : List Style
    , chartCtnrStyles : List Style
    , elemStyles : List Style
    , labelCtnrStyles : List Style
    , labelStyles : List Style
    }

chartInit : List Float -> List String -> ChartType -> Model
chartInit vs ls typ =
    { chartType = typ
    , items = initItems vs ls
    , title = ""
    , containerStyles =
        [ ( "background-color", "#eee" )
        , ( "padding", "15px" )
        , ( "border", "2px solid #aaa" )
        ]
    , chartCtnrStyles =
        [ ( "background-color", "#fff" )
        , ( "padding", "20px 10px" )
        ]
    , elemStyles =
        [ ("font", "10px sans-serif")
        , ("text-align", "right")
        , ("padding", "3px")
        , ("margin", "1px")
        , ("color", "white")
        ]
    , labelCtnrStyles = []
    , labelStyles = []
    }

-- UPDATE

chartTitle : String -> Model -> Model
chartTitle newTitle model =
     { model | title <- newTitle }

normalise : Model -> Model
normalise model =
    case maximum (map .value model.items) of
        Nothing -> model
        Just maxD ->
            { model |
                items <- map (\item -> { item | normValue <- item.value / maxD * 100 }) model.items
            }

-- adds the value of the item to the label
addValueToLabel : Model -> Model
addValueToLabel model =
    { model |
        items <- map (\item -> { item | label <- item.label ++ " " ++ toString item.value }) model.items
    }

-- UPDATE Styles

changeStyles : Style -> List Style -> List Style
changeStyles (attr, val) styles =
    (attr, val) :: (filter (\(t,_) -> t /= attr) styles)

containerStyles : List Style -> Model -> Model
containerStyles lst model =
    { model | containerStyles <- foldl changeStyles model.containerStyles lst }

chartCtnrStyles : List Style -> Model -> Model
chartCtnrStyles lst model =
    { model | chartCtnrStyles <- foldl changeStyles model.chartCtnrStyles lst }

elemStyles : List Style -> Model -> Model
elemStyles lst model =
    { model | elemStyles <- foldl changeStyles model.elemStyles lst }

labelCtnrStyles : List Style -> Model -> Model
labelCtnrStyles lst model =
    { model | labelCtnrStyles <- foldl changeStyles model.labelCtnrStyles lst }

labelStyles : List Style -> Model -> Model
labelStyles lst model =
    { model | labelStyles <- foldl changeStyles model.labelStyles lst }

-- VIEW


toHtml : Model -> Html
toHtml model =
    case model.chartType of
        BarHorizontal -> viewBarHorizontal model
        BarVertical -> viewBarVertical model

viewBarHorizontal : Model -> Html
viewBarHorizontal model =
    div [ style model.containerStyles ]
        [ h3 [ titleStyle ] [ text model.title ]
        , div [ style model.chartCtnrStyles ] <|
            map
                (\{normValue, label} -> div [ style <| ("width", toString normValue ++ "%") :: model.elemStyles] [ text label ] )
                model.items
        ]

viewBarVertical : Model -> Html
viewBarVertical model =
    div [ style model.containerStyles ]
        [ h3 [ titleStyle ] [ text model.title ]
        , div [ style model.chartCtnrStyles ] <|
            map
                (\{normValue} -> div [ style <| ("height", toString normValue ++ "%") :: model.elemStyles] [  ] )
                model.items
        , div [ style model.labelCtnrStyles ] <|
            indexedMap
                ( \idx item ->
                    div [ style <| (labelTransform idx) :: model.labelStyles ] [text (.label item)] ) model.items
        ]


labelTransform : Int -> Style
labelTransform idx =
    let offset = toString <| (2 - idx) * 40 - 25
    in ("transform", "translateX("++offset++"px) translateY(30px) rotate(-45deg)")

titleStyle = style [("text-align", "center")]
