#import "@preview/touying:0.6.1": *
#import "theme.typ": *

#show: university-theme.with(
  aspect-ratio: "16-9",
  nusp: ([13695956], [32165464532]),
  config-info(
    title: [Navegação Autônoma com Controle Preditivo (MPC)],
    subtitle: [Controle Não Linear],
    authors: ("Alan José", "Lucas Franco"),
    date: datetime.today(),
    institution: [Felipe Miguel Pait],
  ),
)

#set grid(column-gutter: 10mm)
#set par(justify: true)
#set text(size: 17pt)
#show math.equation: set text(size: 20pt)


#title-slide()

== Introdução

#[
  #set text(size: 20pt)
#grid(
  columns: (1fr, 1fr), row-gutter: 5mm,
  rows: (1fr, 1.2fr),
  [
    === Objetivo
    
    Navegar de forma autônoma em um percurso aberto, passando por marcos em ordem específica, no menor tempo possível
  ],
  {
    set align(center+horizon)
    place(center, dy: 1.09cm)[#image("images/rota3.png", height: 9.3cm)]
  },
  {
    set align(center+horizon)
    place(center, dy: -1.2cm)[#image("images/pista.png", height: 9cm)]
  },
  [
    #v(2cm)
    === Restrições

    - Os obstáculos impedem uma rota trivial
    - A rota relativamente pequena torna inviável o uso de GPS
    - Não temos os melhores sensores
  ]
)
]

== Controle Lateral

É o que efetivamente fará o robô seguir uma trajetória predefinida

#v(-4mm)
  #align(center)[
    #image("images/trajectory.png", height: 6.92cm)
  ]

#[
#set text(size: 10pt)
#show strong: set text(size: 14pt)
  
#grid(
  columns: (1fr,1fr,1fr,1fr), column-gutter: 2mm,
  [
    *Controlador PID*

    Como funciona:
      - Reage a erros atuais e passados.\
        Simples de implementar
    Problema:
    - É puramente reativo. Em alta velocidade, isso causa oscilações e instabilidade. Não considera os limites físicos do robô (ex: ângulo máximo de esterçamento).
  ],
  [
    *Regulador LQR*
    
    Como funciona: 
- Usa um modelo matemático para otimizar o controle, sendo mais sistemático que o PID. 
Problema: 
- Exige um modelo linear do robô, o que não representa bem a realidade em curvas e altas velocidades. Também não lida com restrições de forma nativa. 

  ],
  [
    *Lógica Fuzzy*
    
    Como funciona: 
- Usa regras linguísticas ("SE o erro é grande, ENTÃO vire muito") em vez de um modelo matemático preciso. 
Problema: 
- Não garante uma solução ótima e sua sintonia é complexa e heurística, sem garantias de estabilidade. 

  ],
  [
    *Model Predictive Control*
    
    Como funciona: 
- Um controlador avançado que utiliza um modelo para prever o comportamento futuro do robô.
Simula várias sequências de controle futuras em um horizonte de tempo finito.
Problema: 
- Requer alto poder computacional

  ]
  
)

]

== Controle Preditivo

#grid(
  columns: (1fr, 1fr), rows: 1fr, align: horizon, column-gutter: 10mm,
  align(horizon+center,
    image("images/mpc diagram.png")
  ),
  [
    #set text(size: 14pt)
    #set par(spacing: 10mm)
    Preditivo: 
- Utiliza um modelo para "olhar à frente" e prever o comportamento futuro do robô, permitindo ações proativas em vez de apenas reativas. 
Otimizado: 
- A cada instante, ele resolve um problema de otimização para encontrar a melhor sequência de comandos que minimiza erros e esforço de controle. 
Capaz de Lidar com Restrições: 
- Esta é a maior vantagem. Os limites físicos do robô (velocidade máxima, ângulo de esterçamento, etc.) são incluídos diretamente no problema de otimização. Isso garante que os comandos gerados sejam sempre realistas e seguros. 
Ideal para Sistemas Não-Lineares: 
- Consegue lidar com a dinâmica complexa de um veículo, algo que controladores lineares como PID e LQR não fazem bem. 

  ]
)

#pagebreak()

#grid(
  columns: (1fr, 1fr),
  [
    === Principios Fundamentais
    
    #set text(size: 16pt)
    
    O MPC funciona em um ciclo contínuo de Horizonte Recedente:
+ PREVER: No instante atual, usa um modelo matemático para prever a trajetória do robô para os próximos segundos (o "horizonte de predição"). 
+ OTIMIZAR: Calcula a sequência de comandos (velocidade e direção) que minimiza uma função de custo ao longo desse horizonte, respeitando todas as restrições físicas. 
+ APLICAR E REPETIR: Aplica apenas o primeiro comando da sequência ótima. Em seguida, mede o novo estado do robô, descarta o resto do plano e recomeça todo o processo. 

  ],
  [
    === Função de Custo
    
    #set text(size: 16pt)
    
    A "mágica" do MPC está na sua função de custo, que define o comportamento do robô. Ela busca um balanço ótimo entre objetivos conflitantes:
    - Minimizar o Erro de Trajetória: 
      - Manter o robô o mais próximo possível do caminho planejado (foco em precisão). 
    - Minimizar o Esforço de Controle: 
      - Penalizar o uso excessivo dos motores e do volante (foco em eficiência e suavidade). 
    - Minimizar Mudanças Bruscas: 
      - Penalizar variações rápidas nos comandos para evitar movimentos agressivos (foco em estabilidade). 
    Ajustar os pesos de cada termo é como definir a personalidade do piloto: mais agressivo ou mais conservador.

  ]
)

== LMPC vs NLMPC

#[
  #set par(justify: true)
#grid(columns: (1fr, 1.2fr), rows: 1fr, align: horizon, inset: (bottom: 7mm),
  image("images/mpc tracking diagram.png", width: 100%),
  [
    #set text(size: 13pt)
    #show heading.where(level: 3): set text(size: 20pt)
    #set align(center)
    #grid(columns: 1, row-gutter: 1fr,
      [
        === Qual modelo de MPC?
    
        A performance do MPC depende diretamente da qualidade do seu modelo de predição. Existem duas abordagens principais:
      ],
      [
        #grid(columns: 2, column-gutter: 5mm, align: top,
        [
          === MPC Linear
    
           Usa uma versão simplificada e linearizada da dinâmica do robô. É computacionalmente mais leve, mas perde precisão quando o robô se afasta do ponto de linearização (ex: em curvas fechadas). 
        ],
        [
          === MPC Não Linear
    
          Utiliza o modelo não-linear completo do robô, capturando sua dinâmica com alta fidelidade em todas as condições.
        ])
      ],
      [
        === Nossa escolha: NLMPC
    
        A competição exige operar nos limites de performance em um terreno irregular. A precisão superior do NMPC é crucial para prever e controlar o robô de forma segura e rápida em altas velocidades e curvas, superando as limitações dos modelos lineares. Embora seja computacionalmente mais caro, ele oferece o maior potencial de desempenho.
      ]
    )
  ]
)
]

== Modelo Bicicleta

#grid(columns: (1fr, 1fr), rows: 1fr,
[
  #set text(size: 17pt)
  Essa modelagem não leva em consideração propriedades dinâmicas, como forças e atrito. Porém, é um modelo que funciona relativamente bem por ser simples e fácil de computar

  #set align(horizon)
  #image("images/car_like_robot.svg", width: 100%)
],
[
  === Dinâmica dos estados
  $
    cases(
      dot(x) = v cos(theta),
      dot(y) = v sin(theta),
      dot(theta) = v/l tan(delta)
    )
  $

  Onde:

  #set par(leading: 3mm)
  $
  (x,y,theta) & #[é a pose do robô] \
            v & #[é a velocidade] \
        delta & #[é o ângulo de esterçamento] \
            l & #[é a distância entre eixos]
  $

  Normalmente o sistema acima seria linearizado para obter uma representação em espaço de estados, porém como vamos utilizar um NLMPC, essa etapa é desnecessária
]

)

#pagebreak()

=== Integração

Será visto a diante que será necessário impor restrições nos estados futuros.\
A previsão dos estados futuros é feita integrando a dinâmica dos estados a partir de um estado inicial com um tempo de amostragem $T_s$

$
x_(k+1) = x_k + T_s f(t_k, x_k) #box(place(bottom, [(Método de Euler)]))
$

Onde $f(t, x)$ é a função não linear da dinâmica dos estados

$
cases(
  dot(x) = f(t, x),
  x(t_0) = x_0
)
$
Embora o método de Euler seja fácil de implementar, é mais adequado utilizar o método de #box[*Runge-Kutta*], por ser mais estável

#grid(columns: (1fr, 1fr), rows: 1fr,
$
\ 
x_(k+1) = 1/6 T_s (s_1 + 2s_2 + 2s_3 + s_4)
$,place(center, dy: -11mm)[
  #show math.equation: set text(20pt)
  $
  cases(
    s_1 = f(t_k, x_k),
    s_2 = f(t_k + T_s/2, x_k + T_s s_1/2),
    s_3 = f(t_k + T_s/2, x_k + T_s s_2/2),
    s_4 = f(t_k + T_s, x_k + T_s s_3),
  )
  $
]

)

== Problema de Otimização

Esse é o problema que será resolvido a cada loop de controle

$
&min_(u) J(x_0, u) = sum_(k=0)^N x_e^T Q x_e + u_e^T R u_e \
"sujeito a"& \
&cases(
  x(0) = x_0,
  x_(k+1)=f(x_k, u_k)\; quad k in {0,1,...,N-1},
  x_min <= x_k <= x_max\; quad k in {1,2,...,N},
  u_min <= u_k <= u_max\; quad k in {0,1,...,N-1}
)
$

#grid(columns: (1fr, 1fr, 1cm), rows: (5mm,4cm), align: (center+horizon, horizon),
[*Variáveis*],[],[],
[  
 $
  u_e &= u - u_r \
  x_e &= underbrace(x, "estados" \ "no horizonte") - underbrace(x_r, "referência")
  $ 
],
  [
    $Q$ e $R$ são matrizes simétricas positivas que definem o peso nos erros de estado e esforços de controle
  ]
)

== Fluxo de Controle

#[
  #set align(center+horizon) 
  #image("images/Perse MPC.drawio.svg", width: 26cm)
]

== Nossa Implementação

=== Modelo

#[
#set math.vec(delim: none)
$
  cases(
      dot(x) = "PWM"  v_"nominal" cos(theta),
      dot(y) = "PWM" v_"nominal" sin(theta),
      dot(theta) = ("PWM"  v_"nominal")/l tan(delta)
    )
    quad
    "onde:" 
    #math.vec(
      ..(
        [
          #set math.cases(reverse: true)
          $
            &cases(
              x :& " posição x do C.M.",
              y :& " posição y do C.M.",
              theta :& " ângulo z do C.M."
            ) " " x "(Estados)"
          $
        ], 
        [
          #set math.cases(reverse: true)
          $
            &cases(
              "PWM":& " setpoint de velocidade",
              delta :& " ângulo de esterçamento"
            ) " " u "(Ações)"
          $
        ]
      )
    )
$
]

#grid(columns: (1fr,1.1fr),
  [
    === Parâmetros do Modelo

    #[
      #show strong: it => [
        #set text(fill: black, size: 15pt)
        #text(it.body, weight: "semibold")
      ]
      #table(
        columns: 3, align: horizon,
        [
          *Nome*
        ],[*Valor*],[*Descrição*],
        $ v_"nominal" $, [5 m/s], [Velocidade máxima do robô],
        $ l $, [30 cm], [Distância entre as rodas frontal e traseira],
      )
    ]
    === Software

    Utilizamos a biblioteca Acados. Com ela nós modelamos o sistema em python e geramos um código otimizado em C++ para execução
    
  ],
  [
    === Parâmetros do Otimizador

    #[
      #show strong: it => [
        #set text(fill: black, size: 15pt)
        #text(it.body, weight: "semibold")
      ]
      #table(
        columns: 3, align: (horizon+center, horizon+center, horizon),
        [
          *Nome*
        ],[*Valor*],align(center)[*Descrição*],
        $ T_f $, [1 $"s"$], [Tempo do horizonte],
        $ l $, [30 $"cm"$], [Distância entre as rodas frontal e traseira],
        $ N $, [ 20 ], [ Passos do horizonte],
        $ u_min, u_max $, box(inset: (y: 2mm))[ $ plus.minus 1$ e $ plus.minus pi/4$], [Limites de controle],
        [Integrador], [RK4], [Método de Runge-Kutta],
        $ T_s $, box(inset: (y: 3mm))[ $T_f/N =0.05 space "s"$ ], [Período de controle]
      )
    ]
  ]
)

#pagebreak()

=== Pesos

#let diag(..args) = {
  let nums = args.pos()
  let N = nums.len()
  let zeros = array.range(N).map(it => 
    array.range(N).map(it => 0)
  )
  for (i,num) in nums.enumerate() {
    zeros.at(i).at(i) = num
  }
  zeros
}
#[

#let s = 13mm
$
Q = limits(#math.mat(..diag(1000,1000,500)))^(x  #h(s) y #h(s) theta)
quad
R = limits(#math.mat(..diag(500, 650)))^("PWM" #h(3mm) delta)
$

]

#align(center+horizon)[
  Obs.: A última posição do horizonte é utilizado apenas o peso de estados
]

== Resultados

#place(center+horizon, dy:5mm)[
  #image("images/Trajetoria Python.svg", width: 18cm)
]

#pagebreak()

#grid(columns: (1fr, 1fr), column-gutter: -13mm,
image("images/grafico esforcos.svg", width: 100%),
image("images/grafico estados.svg", width: 100%)
)

== Resultados (Webots)

#[
  #set align(center+horizon)
  #link("https://drive.google.com/file/d/1sWCYufGtvxPuHyVq8ismmpKFtk0ph4ZP/view?usp=sharing")[
    #box[
      #align(center+horizon)[
        #image("images/webots.png", width: 25cm)
      ]
      #place(center+horizon)[
        #circle(radius: 2cm, fill: black.transparentize(10%))    
      ]
      #place(center+horizon, dx: 2.5mm)[
        #rotate(90deg)[
          #polygon.regular(
            fill: white,
            size: 50pt,
            vertices: 3,
          )
        ]
      ]
    ]
  ]
]

== Próximos Passos

- Implementar restrições de obstáculos

$
sqrt(
  (x_"robo"-x_"obs")^2 + (y_"robo"-y_"obs")^2
) >= (r_"robo" + r_"obs")
$

- Melhorar o modelo usado no MPC para melhor representar a simulação do Webots (e a realidade)
- Estudar a viabilidade de um modelo mais completo, com atrito e caracteristicas dinâmicas quando em altas velocidades
- Implementar em um hardware real

#grid(columns: (1fr, 1.3fr), align: center+horizon,
  [
    #v(7mm)
    #link("https://github.com/IntelligentControlSystems/ClutteredEnvironment")[
      #image("images/cluttered github.jpg")
    ]
  ],
  place(center, dy: -19mm)[
    #image("images/cluttered_mpc_sim.gif", width: 16cm)
  ]
)

= Fim