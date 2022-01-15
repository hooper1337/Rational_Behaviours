; Definição de variáveis
breed [comiloes comilao]
breed [limpadores limpador]
;breed [toxicos toxico]                      ; novo agente que limpa apenas o lixo toxico e tem percepçoes iguais as dos comiloes
turtles-own [energia]
limpadores-own [deposito-limpador]
;toxicos-own [deposito-limpador]

; Configuração do ambiente
to setup
  clear-all
  Setup-patches
  Setup-turtles
  reset-ticks
end

to Go
  ask turtles with [energia <= 0] [ die ]            ; Se a energia chegar a zero morrem
  if count turtles = 0 [ stop ]                      ; Se não houverem agentes para
  movimentacaoComiloes
  movimentacaoLimpadores
  ;movimentacaoToxicos
  limpar
  comer
  despejar
  ;reproduzir
  tick
  mostraLabels
end

to Setup-Patches                   ; Procedimento para configurar o ambiente
  clear-all
  set-patch-size 15

  ask patches[
    if random 101 < Lixo_Normal    ; Setup de patches para Lixo Normal
    [set pcolor yellow]

    if random 101 < Lixo_Toxico    ; Setup de patches para Lixo Toxico
    [set pcolor red]

    if random 101 < Alimento       ; Setup de patches para Alimento
    [set pcolor green]

    if random 101 < Depositos      ; Setup de patches para os Depositos
    [set pcolor blue]
  ]

  ask patches with [               ; Define a cor cinzenta para o limite da grelha
    pxcor = max-pxcor or
    pxcor = min-pxcor or
    pycor = max-pycor or
    pycor = min-pycor ] [
    set pcolor grey
  ]
end

to Setup-Turtles                   ; Procedimento para configurar os agentes

  create-comiloes Numero_Comiloes  ; Setup nos comiloes
  [
    set shape "turtle"
    set color brown
    set size 1.5
    setxy random-xcor random-ycor
    while[[pcolor] of patch-here != black] ; Agentes só dão spawn nas células pretas
    [setxy random-xcor random-ycor]
    set energia Energia_Inicial_Agentes
  ]


  create-limpadores Numero_Limpadores  ; Setup nos limpadores
  [
    set shape "arrow"
    set color pink
    set size 1.5
    setxy random-xcor random-ycor
    while[[pcolor] of patch-here != black]
    [setxy random-xcor random-ycor]
    set energia Energia_Inicial_Agentes
  ]
;  create-toxicos Numero_Toxicos          ; Os Limpadores apenas de Lixo toxico são 10 por centos dos Limpadores normais
;  [
;    set shape "arrow"
;    set color violet
;    set size 1.5
;    setxy random-xcor random-ycor
;    while[[pcolor] of patch-here != black]
;    [setxy random-xcor random-ycor]
;    set energia Energia_Inicial_Agentes
;
;  ]
  mostraLabels
end

; Procedimento do interruptor para mostrar energia dos agentes
to mostraLabels
  ask turtles
  [
    if Mostra_Energia
    [
      set label energia
    ]
  ]
end

to comer
  ask turtles[
    if[pcolor] of patch-here = green
    [
      set pcolor black
      set energia energia + Alimento_Energia
      ask one-of patches with [pcolor = black]
      [ ; repões o alimento mal é comido
        set pcolor green
      ]
    ]
  ]
end


to movimentacaoComiloes
  ask comiloes [

    set energia energia - 1                                  ; a cada percecao o agente perde energia
    ifelse [pcolor] of patch-here = grey
    or [pcolor] of patch-ahead 1 = grey
    [ ; fuga dos limites
      ifelse random 101 <= 51
      [ rt 90 ]
      [ lt 90 ]
      fd 1
    ]
    [                   ; percepçao do alimento
      ifelse [pcolor] of patch-ahead 1 = green[             ; se tiveres alimento à frente avanças
        fd 1
      ]
      [
        ifelse [pcolor] of patch-right-and-ahead 90 1 = green[   ; se tiveres alimento à direita rodas para a direita
          right 90
        ]
        [
          ifelse [pcolor] of patch-left-and-ahead 90 1 = green[     ; se tiveres alimento à esquerda rodas para a esquerda
            left 90
          ]
          [           ; percepção de lixo normal
            ifelse [pcolor] of patch-ahead 1 = yellow[              ; se percecionares lixo normal a frente, perdes energia e rodas 50% das vezes para a esquerda e 50% das vezes para a direita
              set energia energia - (energia * 0.05)
              ifelse random 101 < 50 [right 90] [left 90]
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = yellow[    ; ser percecionares lixo normal a direita, 50% das vezes rodas para a esquerda e outras 50% avanças uma patch
                set energia energia - (energia * 0.05)
                ifelse random 101 < 50 [forward 1][left 90]
              ]
              [
                ifelse [pcolor] of patch-left-and-ahead 90 1 = yellow[        ; ser percecionares lixo normal a esquerda, 50% das vezes rodas para a direita e outras 50% avanças uma patch
                  set energia energia - (energia * 0.05)
                  ifelse random 101 < 50 [forward 1][right 90]
                ]
                [          ; percepçao de lixo toxico
                  ifelse [pcolor] of patch-ahead 1 = red[                    ; igual ao lixo normal
                    set energia energia - (energia * 0.10)
                    ifelse random 101 < 50 [right 90][left 90]
                  ]
                  [
                    ifelse [pcolor] of patch-right-and-ahead 90 1 = red[
                      set energia energia - (energia * 0.10)
                      ifelse random 101 < 50 [forward 1] [left 90]
                    ]
                    [
                      ifelse [pcolor] of patch-left-and-ahead 90 1 = red[
                        set energia energia - (energia * 0.10)
                        ifelse random 101 < 50 [forward 1][right 90]
                      ]
                      [                ; agente em cima de lixo toxico morre
                        ifelse[pcolor] of patch-here = red [die]
                        [              ; agente em cima de lixo normal morre
                          ifelse [pcolor] of patch-here = yellow [die]
                          [
                            ifelse random 101 < 33 [forward 1]
                            [ifelse random 101 < 66 [right 90][left 90]]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to movimentacaoLimpadores
  ask limpadores[
    set energia energia - 1
    ifelse [pcolor] of patch-here = grey
    or [pcolor] of patch-ahead 1 = grey
    [ ; fuga dos limites
      ifelse random 101 <= 51
      [ rt 90 ]
      [ lt 90 ]
      fd 1
    ]
    [         ; percepção do alimento
      ifelse [pcolor] of patch-ahead 1 = green[                               ; se tiveres alimento a frente avanças
        fd 1
      ]
      [
        ifelse [pcolor] of patch-right-and-ahead 90 1 = green[                ; se tiveres alimento a tua direita roda para la
          right 90
        ]
        [             ; verificar se o depósito está cheio
          ifelse deposito-limpador = Tamanho_Deposito_Limpador[
            ifelse [pcolor] of patch-ahead 1 = blue[                 ; despejar se  tiveres um deposito a tua frente
              forward 1
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = blue[     ; se tiveres um deposito a direita roda para la
                right 90
              ]
              [
                ifelse random 101 < 33[
                  forward 1                                            ; se não for nenhum dos casos vais a procura para a frente, rodar para a esquerda ou direita
                ]
                [
                  ifelse random 101 < 66 [right 90] [left 90]
                ]
              ]
            ]
          ]
          [
            ifelse [pcolor] of patch-ahead 1 = red[                                  ; se tiveres lixo toxico a frente e tiveres espaço, avança para limpares
              ifelse deposito-limpador < Tamanho_Deposito_Limpador - 1 [forward 1]
              [
                ifelse [pcolor] of patch-right-and-ahead 90 1 = yellow[              ; se for amarela roda para la para limpares
                  right 90
                ]
                [
                  ifelse [pcolor] of patch-right-and-ahead 90 1 = red [left 90]       ; se tiveres a tua direita vermelho nao interessa porque nao tens espaço e depois vais ao calhas(rodar esquerda ou direita ou avanças)
                  [
                    ifelse random 101 < 50 [left 90] [right 90]
                  ]
                ]
              ]
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = red[                             ; se encontrares lixo toxico a direita e tiveres espaço roda para ka, se nao rodas para a esquerda
                ifelse deposito-limpador < Tamanho_Deposito_Limpador - 1 [right 90] [left 90]
              ]
              [
                ifelse [pcolor] of patch-ahead 1 = yellow [forward 1]                     ; se tiveres lixo normal a frente avança para limpares
                [
                  ifelse [pcolor] of patch-right-and-ahead 90 1 = yellow [right 90]      ; se tiveres lixo normal a direita roda para la
                  [
                    ifelse random 101 < 33 [forward 1]
                    [                                                                   ; se não vais ao calhas a procura(rodas par a direita ou esquerda ou vais para a frente
                      ifelse random 101 < 66 [right 90] [left 90]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

;to movimentacaoToxicos
;  ask toxicos [
;    set energia energia - 1
;    ifelse [pcolor] of patch-here = grey
;    or [pcolor] of patch-ahead 1 = grey
;    [
;      ifelse random 100 <= 51 [rt 90] [lt 90]
;      forward 1
;    ]
;    [
;      ifelse [pcolor] of patch-ahead 1 = green[                                            ; verificas se tens comida a frente e se tiveres avanças
;        forward 1
;      ]
;      [
;        ifelse [pcolor] of patch-right-and-ahead 90 1 = green[                             ; verificas se tens comida a direita e preparas-te para ir para lá
;          rt 90
;        ]
;        [
;          ifelse [pcolor] of patch-left-and-ahead 90 1 = green[                            ; verificas se tens comida a esquerda e preparas-te para ir para lá
;            lt 90
;          ]
;          [
;            ifelse deposito-limpador = Tamanho_Deposito_Limpador[                         ; verificas se tens o deposito cheio, se tiveres cheio e tiveres um deposito a frente avanças para lá
;              ifelse [pcolor] of patch-ahead 1 = blue[
;                forward 1
;              ]
;              [                                                                           ; se nao tiveres a frente, verificas se tens a direita um deposito e preparas-te para ir para la se tiveres
;                ifelse [pcolor] of patch-right-and-ahead 90 1 = blue[
;                  rt 90
;                ]
;                [
;                  ifelse [pcolor] of patch-left-and-ahead 90 1 = blue[                    ; se nao tiveres a direita verificas se tens a esquerda um deposito e preparas-te para ir para la se tiveres
;                    lt 90
;                  ]
;                  [
;                    ifelse random 101 < 33[                                               ; se nao vais para a frente, rodas para a direita ou esquerda a procura de um deposito
;                      forward 1
;                    ]
;                    [
;                      ifelse random 101 < 66 [right 90][left 90]
;                    ]
;                  ]
;                ]
;              ]
;            ]
;            [
;              ifelse [pcolor] of patch-ahead 1 = red[                                        ; verificas se tens lixo toxixo a frente e se tiveres espaço para despejar avanças para la
;                ifelse deposito-limpador < Tamanho_Deposito_Limpador - 1 [forward 1]
;                [
;                  ifelse [pcolor] of patch-right-and-ahead 90 1 = blue[                      ; verificas se tens deposito a direita ou esquerda e caso tenhas preparas-te para ir para la
;                    rt 90
;                  ]
;                  [
;                    ifelse [pcolor]of patch-left-and-ahead 90 1 = blue[
;                      lt 90
;                    ]
;                    [
;                      ifelse random 101 < 33 [forward 1]                                      ; se não vais para a frente, rodas para a esquerda ou direita a procura de um deposito
;                      [
;                        ifelse random 101 < 66 [rt 90] [lt 90]
;                      ]
;                    ]
;                  ]
;                ]
;              ]
;              [
;                ifelse [pcolor] of patch-right-and-ahead 90 1 = red[                         ; procuras por lixo toxico a direita ou esquerda e se encontrares preparas-te para ir para la
;                  rt 90
;                ]
;                [
;                  ifelse [pcolor] of patch-left-and-ahead 90 1 = red[
;                    lt 90
;                  ]
;                  [
;                    ifelse random 101 < 33 [forward 1]                                       ; se não mais uma vez vais random a procura de lixo toxico
;                    [
;                      ifelse random 101 < 66 [rt 90] [lt 90]
;                    ]
;                  ]
;                ]
;              ]
;            ]
;          ]
;        ]
;      ]
;    ]
;  ]
;end

to despejar                                         ; se o limpador estiver num depósito limpar o lixo e aumentas 10x o que depositaste a tua energia
  ask limpadores[
    if [pcolor] of patch-here = blue[
      set energia energia + 10 * deposito-limpador
      set deposito-limpador 0
    ]
  ]
;    ask toxicos[
;    if [pcolor] of patch-here = blue[
;      set energia energia + 10 * deposito-limpador
;      set deposito-limpador 0
;    ]
;  ]
end

to limpar          ;limpar o lixo
  ask limpadores[

    if [pcolor] of patch-here = red
    [                                                                   ; limpar o lixo toxico
      if deposito-limpador < Tamanho_Deposito_Limpador - 1
      [set pcolor black
        set deposito-limpador deposito-limpador + 2
        ask one-of patches with [pcolor = black]                         ; cada vez que o limpador limpa lixo toxico e automaticamente reposto
      [
        set pcolor red
      ]
      ]
    ]
    if [pcolor] of patch-here = yellow                                  ; limpar o lixo normal
    [
      set pcolor black
      set deposito-limpador deposito-limpador + 1
      ask one-of patches with [pcolor = black]
      [
        set pcolor yellow                                                ; cada vez que o limpador limpa lixo normal e automaticamente reposto
      ]
    ]
  ]
;  ask toxicos[
;    if [pcolor] of patch-here = red
;    [                                                                   ; limpar o lixo toxico
;      if deposito-limpador < Tamanho_Deposito_Limpador - 1
;      [set pcolor black
;        set deposito-limpador deposito-limpador + 2
;        ask one-of patches with [pcolor = black]                         ; cada vez que o limpador limpa lixo toxico e automaticamente reposto
;      [
;        set pcolor red
;      ]
;      ]
;    ]
;  ]
end

;to reproduzir
;  ask comiloes[
;    if (any? comiloes-on patch-here) and (count turtles-on patch-here = 2)[
;      if random 100 < Taxa_Reproducao[                                        ; slider para a taxa de reproduçao na interface
;        hatch 1[
;          set energia Energia_Inicial_Agentes
;        ]
;      ]
;    ]
;  ]
;end
@#$#@#$#@
GRAPHICS-WINDOW
473
48
976
552
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
15
58
79
91
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
111
185
144
Lixo_Normal
Lixo_Normal
0
15
10.0
1
1
NIL
HORIZONTAL

SLIDER
13
158
185
191
Lixo_Toxico
Lixo_Toxico
0
15
10.0
1
1
NIL
HORIZONTAL

SLIDER
13
204
185
237
Alimento
Alimento
5
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
13
247
185
280
Alimento_Energia
Alimento_Energia
1
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
13
295
185
328
Depositos
Depositos
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
215
111
387
144
Numero_Comiloes
Numero_Comiloes
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
214
159
386
192
Numero_Limpadores
Numero_Limpadores
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
213
206
387
239
Energia_Inicial_Agentes
Energia_Inicial_Agentes
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
210
250
387
283
Tamanho_Deposito_Limpador
Tamanho_Deposito_Limpador
1
10
4.0
1
1
NIL
HORIZONTAL

SWITCH
211
296
334
329
Mostra_Energia
Mostra_Energia
1
1
-1000

BUTTON
122
58
185
91
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
14
340
76
385
Comilões
count comiloes
17
1
11

MONITOR
89
339
164
384
Limpadores
count limpadores
17
1
11

PLOT
13
397
235
561
Agentes 
Tempo
Número de Agentes 
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Comilões" 1.0 0 -6459832 true "" "plot count comiloes"
"Limpadores" 1.0 0 -2064490 true "" "plot count limpadores"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
