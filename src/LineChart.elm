module LineChart exposing (viewLine)

import Color exposing (..)
import Collage as C exposing (..)
import Element
import String
import Text
import Html exposing (Html)
import List exposing (map, length, head)
import ChartModel exposing (..)


-- http://stackoverflow.com/questions/361681/algorithm-for-nice-grid-line-intervals-on-a-graph


getTicks : Float -> Float -> Float
getTicks largest mostticks =
    let
        mini =
            largest / mostticks

        magnitude =
            toFloat <| 10 ^ (floor <| logBase 10 mini / logBase 10 10)

        residual =
            mini / magnitude
    in
        if residual > 5 then
            10 * magnitude
        else if residual > 2 then
            5 * magnitude
        else if residual > 1 then
            2 * magnitude
        else
            magnitude


viewLine : Model -> List (Html a)
viewLine model =
    let
        width =
            400

        height =
            300

        chartW =
            width / 2 - 30

        chartH =
            height / 2 - 40

        noTicks =
            8

        noValues =
            (toFloat << length) model.items

        yVals =
            List.map .value model.items

        tickIncrement =
            getTicks (Maybe.withDefault 0 <| List.maximum yVals) noTicks

        maxY =
            tickIncrement * noTicks

        lineStyle =
            { defaultLine | width = 8, color = lightBlue, join = Smooth }

        yaxis =
            traced
                defaultLine
                (segment ( -chartW, -chartH ) ( -chartW, chartH ))
                :: (List.map (\i -> toFloat i * tickIncrement) (List.range 0 noTicks)
                        |> List.map makeYTick
                        |> List.indexedMap (\i -> C.move ( -chartW, (toFloat i) * (chartH * 2 / noTicks) - chartH ))
                   )

        xaxis =
            traced
                -- x-axis
                defaultLine
                (segment ( -chartW, -chartH ) ( chartW, -chartH ))
                :: (List.map makeXTick (List.map .label model.items)
                        |> List.indexedMap (\i -> C.move ( (toFloat i + 0.5) * (chartW * 2 / noValues) - chartW, -chartH ))
                   )

        val2point : Int -> Float -> ( Float, Float )
        val2point i v =
            let
                xSpacing =
                    (2 * chartW) / noValues
            in
                ( (toFloat i + 0.5) * xSpacing - chartW
                , v / maxY * chartH * 2 - chartH
                )
    in
        [ Element.toHtml <|
            collage 400 300 <|
                [ rect 400 300
                    |> filled white
                , traced
                    -- line itself
                    lineStyle
                    (path <| List.indexedMap val2point yVals)
                ]
                    ++ yaxis
                    ++ xaxis
        ]



-- returns tick and the value


makeYTick : Float -> Form
makeYTick tVal =
    let
        l =
            String.length (toString tVal)
    in
        group
            [ traced defaultLine (segment ( -5, 0 ) ( 0, 0 ))
            , toString tVal
                |> Text.fromString
                |> C.text
                |> C.move ( (toFloat l) * -3.5 - 7, 2 )
            ]


makeXTick : String -> Form
makeXTick tVal =
    group
        [ traced defaultLine (segment ( 0, -5 ) ( 0, 0 ))
        , String.left 4 tVal
            |> Text.fromString
            |> C.text
            -- |> Text.style [ ("width", "20px"), ("overflow-x", "hidden") ]
            |>
                C.rotate (degrees 45)
            |> C.move ( 0, -20 )
        ]



-- hexString : String -> Color
-- hexString s =
--     String.dropLeft 1 s
--         |> String.slice Int Int String
