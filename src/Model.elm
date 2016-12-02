module Model exposing (ChartType(..), Model, Style, initItem, initItems, chartInit)

import Dict exposing (Dict, update, get)


type ChartType
    = BarHorizontal
    | BarVertical
    | Pie
    | Line


type alias Item =
    { value : Float
    , normValue : Float
    , label : String
    }


initItem : Float -> String -> Item
initItem v l =
    { value = v
    , normValue = 0
    , label = l
    }


type alias Items =
    List Item


initItems : List ( Float, String ) -> Items
initItems =
    List.map (uncurry initItem)



-- List.map2 initItem


type alias Style =
    ( String, String )


type alias Model =
    { chartType : ChartType
    , items : Items
    , title : String
    , colours : List String
    , styles : Dict String (List Style)
    }


chartInit : List ( Float, String ) -> ChartType -> Model
chartInit vs typ =
    { chartType = typ
    , items = initItems vs
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
