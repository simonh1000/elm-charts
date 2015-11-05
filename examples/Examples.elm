module Examples where

import StartApp.Simple exposing (start)

import Html exposing (..)
import Html.Attributes exposing (style)

import Chart exposing (..)

labels =
    [ "Alpha", "Beta"
    , "Gamma is a super long legend entry that will never fit in the area at all"
    , "Delta", "Epsilon", "Lamda"
    , "Omega", "Phi", "zeta"
    ]
values = [5, 9, 5, 2, 6, 1, 1, 1, 12]

type alias Model =
    { labels : List String
    , values : List Float
    }

init =
    { labels = List.take 9 labels
    , values = List.take 9 values
    }

type Action = Dummy

update : Action -> Model -> Model
update action model = model

view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ hBar model.values model.labels
            |> title "Example horizontal bar chart"
            |> toHtml
        , vBar model.values model.labels
            |> title "Example vertical bar chart"
            |> toHtml
        , pie model.values model.labels
            |> title "Example pie chart"
            |> updateStyles "legend"
                [ ("font-size", "25px")
                ]
            |> colours
                [ "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                , "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                , "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                ]
            |> toHtml
        ]

main =
  start
    { model = init
    , update = update
    , view = view
    }
