module Examples exposing (..)

import Html.App as Html

import Html exposing (..)
import Html.Attributes exposing (style)

import Chart exposing (..)

data =
    [ (5, "Alpha")
    , (10, "Beta")
    , (5, "Gamma is a super long legend entry that will never fit in the area at all")
    -- , (2, "Delta")
    -- , (6, "Epsilon")
    -- , (1, "Lamda")
    -- , (1, "Omega")
    -- , (120, "zeta")
    -- , (1, "Phi")
    ]

type alias Model =
    List (Float, String)

init = data

type Msg = Dummy

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( model, Cmd.none )

view : Model -> Html Msg
view model =
    div []
        [ hBar model
            |> title "Example horizontal bar chart"
            |> toHtml
        , vBar model
            |> title "Example vertical bar chart"
            |> toHtml
        , pie model
            |> title "Example pie chart"
            |> addValueToLabel
            |> updateStyles "legend"
                [ ("font-size", "25px")
                ]
            |> colours
                [ "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                , "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                , "#BF69B1", "#96A65B", "#D9A679", "#593F27", "#A63D33"
                ]
            |> toHtml
        , lChart model
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
