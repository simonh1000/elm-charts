module Model exposing (ChartType(..), Model, Style, initItem, initItems, chartInit)

import Dict exposing (Dict, update, get)


type ChartType
    = BarHorizontal
    | BarVertical
    | Pie
    | Line


type alias Model =
    { chartType : ChartType
    , items : List Item
    , width : Int
    , height : Int
    , title : String
    , colours :
        List String
        -- class [(style, value)]
    , styles : Dict String (List Style)
    }


type alias Item =
    { value : Float
    , normValue : Float
    , label : String
    }


type alias Style =
    ( String, String )


initItem : Float -> String -> Item
initItem v l =
    { value = v
    , normValue = 0
    , label = l
    }


initItems : List ( Float, String ) -> List Item
initItems =
    List.map (uncurry initItem)


chartInit : List ( Float, String ) -> ChartType -> Model
chartInit vs typ =
    { chartType = typ
    , items = initItems vs
    , width = 400
    , height = 300
    , title = ""
    , colours = [ "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33" ]
    , styles =
        Dict.fromList
            [ ( "title", [ ( "text-align", "center" ) ] )
            , ( "container"
              , [ ( "background-color", "#eee" )
                , ( "padding", "15px" )
                  -- , ( "border", "2px solid #aaa" )
                , ( "display", "flex" )
                , ( "flex-direction", "column" )
                ]
              )
            , ( "chart-container"
              , [ ( "display", "flex" )
                , ( "background-color", "#fff" )
                , ( "padding", "15px" )
                ]
              )
            , ( "chart"
              , [ ( "display", "flex" ) ]
                -- not needed for Pie
              )
            , ( "chart-elements", [] )
            , ( "legend"
              , [ ( "display", "flex" ) ]
              )
            , ( "legend-labels"
              , [ ( "white-space", "nowrap" )
                , ( "overflow", "hidden" )
                , ( "text-overflow", "ellipsis" )
                ]
              )
            ]
    }
