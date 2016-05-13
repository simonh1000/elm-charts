module Examples exposing (..)

import Html.App as Html

import Html exposing (..)
import Html.Attributes exposing (style)

import Chart exposing (..)

labels =
    [ "Alpha", "Beta"
    , "Gamma is a super long legend entry that will never fit in the area at all"
    , "Delta", "Epsilon", "Lamda"
    , "Omega", "Phi", "zeta"
    ]
values = [5, 9, 5, 2, 6, 1, 1, 1, 120]

type alias Model =
    { labels : List String
    , values : List Float
    }

init =
    { labels = List.take 9 labels
    , values = List.take 9 values
    }

type Msg = Dummy

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( model, Cmd.none )

view : Model -> Html Msg
view model =
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
        , lChart model.values model.labels
            |> title "Example line chart"
            |> toHtml
        ]

main =
  Html.program
    { init = (init, Cmd.none)
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }
