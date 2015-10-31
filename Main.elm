module Main (main) where

import StartApp.Simple exposing (start)

import Effects exposing (Effects, Never)
import Html exposing (..)
import Task

import Chart exposing (..)
--
labels = ["Alpha", "Beta", "GammaGammaGamma", "Delta", "Epsilon", "Omega"]
values = [5, 9, 15, 2, 6, 10]

type alias Model =
    { labels : List String
    , values : List Float
    }
init =
    { labels = List.take 6 labels
    , values = List.take 6 values
    }

type Action = Dummy

update : Action -> Model -> Model
update action model = model

view : Signal.Address Action -> Model -> Html
view address model =
    chartV model.values model.labels "This is the title"

main =
  start
    { model = init
    , update = update
    , view = view
    }
