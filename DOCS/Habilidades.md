# **Habilidades**

# **Funcionamento:**

O sistema foi construído com o objetivo de permitir que os personagens acumulem múltiplas técnicas e tenham grande variedade de opções, mas preservando o espírito tático, tendo que fazer escolhas de que parte dos seus kits são mais apropriadas para as próximas partes da aventura.  
Pensando em explicar isso, essa seção será dividida em 2 partes:

* [**Pontos de Habilidade**](#pontos-de-habilidade-\(ph\):)  
* [**Slots de Sincronia**](#slots-de-sincronia:)

### **Pontos de Habilidade (PH):** {#pontos-de-habilidade-(ph):}

* **Ganho**: O personagem recebe **1 PH** em níveis terminados em 5 (5, 15, 25, etc.) e **2 PH** em cada **Quebra de Limite** (níveis múltiplos de 10).  
* **Acúmulo**: Ao atingir o nível 100, o personagem terá um total de **30** **PH** acumulados para investir.  
* **Aplicação**: Utilizados exclusivamente no sistema de habilidades, um jogador pode investir **2 PH** para criar uma nova habilidade, ou **1 PH** pra modificar uma habilidade existente


### **Slots de Sincronia:** {#slots-de-sincronia:}

* **Descrição:** O sistema de Sincronia define quais habilidades seu personagem pode usar em um determinado momento, e categoriza as habilidades em dois tipos específicos, que ocupam slots diferentes. A quantidade de slots está diretamente relacionada aos [**arquétipos**](?tab=t.ci0ruvpb0f4h)


* **Slots Comuns:** Destinado para técnicas simples e de uso frequente. Geralmente possuem limitações simples e efeitos mais básicos


* **Slots Especiais:** São ocupados por técnicas de alto impacto que possuem limitações severas, seja por terem um custo elevado ou por não poderem ser usadas repetidamente


* **Troca de Loadout:**  Um personagem pode escolher quais habilidades ele quer que ocupem seus slots durante os **Descansos Longos**


* **Habilidades extras:** Alguns tipos de habilidade não ocupam slots, como as de **raça**, **arquétipo**, **histórico**, ou qualquer habilidade proveniente de equipamentos, a não ser que explicitado de outra forma

# **Criação:**

Ao adquirir **PH**, o jogador pode gastar esses pontos entre sessões pra poder criar habilidades novas ou aprimorar suas habilidades já existentes.   
Ao criar uma habilidade, o jogador gasta **2** de **PH** e precisa ficar atento à 3 coisas:

* Habilidades tem alguns parâmetros definidos por padrão. 

  **Ex:** Habilidades que causam dano ou cura direta, por exemplo, tem seus dados de dano ou cura definidos pelo nível, de forma que eles sempre escalam conforme o jogador evolui. Isso quer dizer que o jogador não precisa gastar PH só pra manter impedir suas habilidades antigas de virarem inúteis, mas também quer dizer que o jogador não pode escolher quanto de dano ou cura seus feitiços causam


* Outros parâmetros da habilidade podem ser escolhidos de uma lista de opções:

  **Ex:** Caso você queira adicionar efeitos às habilidades, eles devem ser escolhidos dos [**efeitos**](?tab=t.4rbd5115bb3q#bookmark=id.837lvk3q659b) apresentados pra colocar nela, assim como uma **duração** da tabela que será apresentada mais abaixo

* Fatores de Custo são taxas aditivas, que multiplicam o valor de custo base da sua habilidade pra chegar no custo final

* Por último, o efeito das deve ser escolhido dentre os efeitos desbloqueados nas árvores de habilidade. O escopo do que suas habilidades podem fazer depende das capacidades do personagem.


## **Estrutura:**

Toda habilidade deve ter:

* **Tipo de Sincronia:** Define se a habilidade é simples ou especial


* **Tipo de Habilidade:** Escolha entre Suporte, Tática e Ofensiva


* **Tipo de Alvo:** Se o alvo da habilidade é target, você mesmo ou em área


* **Tipo de Ataque:** Qual defesa a habilidade deve competir contra quando for usada para atacar alguém


* **Tipo de Dano:** Para habilidades que causam dano, é importante especificar que tipo de dano é causado, pra definir as influências de resistências e  fraquezas corretas.

* **Velocidade:** O tempo que a habilidade precisa pra poder ser usada. Se for menor ou igual a 5s, pode ser usada como **Ação Principal**, se for menor ou igual 2s, pode ser usada como **Ação Bônus**, e caso seja maior que 5s, precisa ser preparada usando a **Ação Principal** todos os turnos até ela ser usada automaticamente quando o tempo restante for menor que 5s, ou, opcionalmente, caso o tempo final até ela ficar pronta for menor que 2s, ela pode ser ativada como **Ação Bônus**. Enquanto o jogador estiver preparando uma habilidade, caso ele receba dano, isso exigirá um teste de **Concentração** pra saber se a habilidade será perdida, com todos os recursos envolvidos. Caso um turno se passe e o jogador não use sua ação principal para prepará-la ou a bônus ativá-la, a habilidade será considerada cancelada, e os recursos não serão consumidos 


* **Área:** Caso a habilidade seja em área, essa sessão especifica o formato e tamanho da área. Se a habilidade não for em área, esse campo não precisa estar presente.


* **Alcance:** A distância máxima em que a habilidade atinge seu alvo, ou a distância máxima entre o alvo e o epicentro da área. Se a habilidade for de alvo Self, esse campo não precisa estar presente


* **Efeito:** O que a habilidade faz. Essa é a seção principal da habilidade, que define exatamente o que ela faz e quais fatores afetam seu funcionamento. Por padrão, se um cenário não for incluído no efeito da habilidade, ela não funciona nesse cenário. Excepcionalmente, o mestre pode sobrescrever essa regra


* **Duração:** Caso a habilidade seja de ativação única, esse campo é “instantâneo”. Caso ela exija ativação constante, será até a concentração ser interrompida, e caso tenha algum efeito que dure um número específico de turnos ou minutos, ele deve mostrar esses dados ou duração em minutos


* **Custo Base:** É o custo do recurso principal que você obtém com a sua origem. Nem todas as habilidades tem, e caso a sua não tenha, esse campo é “0”


* **Fator de Custo:** É a soma dos fatores de custo que você ganha ao escolher cada opção de customização da habilidade, adicionado com 1


* **Custo Final:** É o valor em energia que será efetivamente pago ao usar a sua habilidade. É o valor do seu custo base vezes o seu Fator de Custo total


* **Custo Material:** Caso a sua habilidade tenha algum efeito especial, ela certamente terá um custo material, qual item será consumido deve estar presente aqui. Caso a sua habilidade não tenha um custo desses, o campo não precisa estar presente


* **Condições:** A sua habilidade pode ter condições específicas para ser ativada, como forma de compensar um efeito mais poderoso, ou uma versão mais forte dela. Caso exista, ela deve estar nesse campo, se não existir, esse campo pode ser omitido


* **Limite de Usos:** Quantas vezes a sua habilidade pode ser usada e em qual espaço de tempo. Geralmente habilidades simples podem ser usadas múltiplas vezes por descanso curto, ou até mesmo por combate, enquanto que habilidades especiais só podem ser usadas algumas vezes por descanso longo ou por sessão, mas nem todas as habilidades possuem esse tipo de limite. Caso você tenha uma habilidade que não tenha limite de usos, o campo pode ser omitido


* **Efeitos Adicionais:** Efeitos extras que não acontecem durante a habilidade em si. Pode ser um dano/efeito que é aplicado de forma tardia, uma penalidade que você sofre por usar essa habilidade, ou outra coisa do gênero. Se sua habilidade não tiver efeitos adicionais, esse campo pode ser omitido

  ## **Aspectos Fixos:**

* **Efeitos:**  
  * O número de efeitos que uma habilidade pode ter está diretamente relacionada ao seu tier e **tipo de sincronia**, segundo a tabela a seguir:

    

    

| Tiers | Simples | Especial |
| :---: | :---: | :---: |
| Tier 1 | 1 efeito | 2 efeitos |
| Tier 2 | 2 efeitos | 3 efeitos |
| Tier 3 | 3 efeitos | 5 efeitos |
| Tier 4 | 4 efeitos | 6 efeitos |
| Tier 5 | 5 efeitos | 8 efeitos |

    

* **Dano:**   
  * O dano é definido pelo tipo de habilidade e escala com o tier   
  * Por padrão, o dano de habilidades simples **target** são de 1.5x o dano de um **ataque básico** de **armas** na mesma categoria. Os de habilidades especiais são de 2.5x esse valor  
  * Para ataques em área, o dano das habilidades simples é é de 0.75x do causado por **ataques básicos** de **armas** no mesmo nível, enquanto as especiais são de 1.75x esse dano

* **Cura:**   
  * A cura é definida pelo tipo de habilidade e escala com o nível  
  * Por padrão, a cura de habilidades simples **target** são de 2x o dano de um **ataque básico** de armas na mesma categoria. Os de habilidades especiais são de 3x esse valor  
  * Para ataques em área, a cura das habilidades simples é igual do causado por **ataques básicos** de **armas** no mesmo nível, enquanto as especiais são de 2x esse dano

    

* **Área:**  
  * Caso sua habilidade tenha uma área de efeito, você pode escolher qual formato a área terá, entre:  
    * **Quadrilátero**  
    * **Círculo**  
    * **Cone**

      

  * O tamanho base da área que a habilidade vai atingir escala com o nível segundo a tabela abaixo:

    

| Tier | Círculo (Raio) | Quadrado (Lado) | Cone (Comprimento) |
| :---: | :---: | :---: | :---: |
| Tier 1 | 2m | 3m | 2m |
| Tier 2 | 4m | 7m | 6m |
| Tier 3 | 6m | 11m | 10m |
| Tier 4 | 9m | 16m | 16m |
| Tier 5 | 11m | 18m | 20m |

    

  * Na hora de criar habilidades, você pode escolher utilizar qualquer tamanho menor que a base, se for da sua escolha. Isso não reduz o custo final da habilidade  
  * Para habilidades de quadriláteras, o formato não precisa ser necessariamente de um quadrado, mas precisa ser de um quadrilátero com a mesma área de um quadrado de lado especificado no nível   
  * Para cones, para simplificação dos cálculos, o alcance horizontal do cone é igual ao seu comprimento naquele ponto.  
  * Para habilidades em área, você pode optar por sacrificar 50% do efeito da habilidade para aumentar o raio/lado/comprimento em até 50%. O tamanho final não precisa ser 50% maior, mas pra qualquer tamanho maior que o base o efeito da habilidade será reduzido em 50%

* **Custo Base:**  
  * O custo base da habilidade escala com o nível seguindo as seguintes tabelas:  
    * **Simples:**

      

| Tier | Custo Base de Mana |
| :---: | :---: |
| Tier 1 | 8 |
| Tier 2 | 20 |
| Tier 3 | 40 |
| Tier 4 | 65 |
| Tier 5 | 80 |

    * **Especial:**

      

| Tier | Custo Base de Mana |
| :---: | :---: |
| **Tier 1** | 16 |
| **Tier 2** | 35 |
| **Tier 3** | 60 |
| **Tier 4** | 100 |
| **Tier 5** | 125 |

  * Caso sua habilidade seja AoE, ela tem um fator de custo base de \+20%

    

* **Custo Material:**  
  * Quando criando uma habilidade, dependendo das características incluídas, ela pode ter um ou mais custos materiais.  
  * Onde o material for especificado, também haverá um custo em dinheiro ao lado que fala o preço padrão daquele material em uma loja genérica. Em ocasiões especiais, o mestre pode fazer um material ter um custo maior ou menor baseado nas circunstâncias locais  
  * Geralmente, o material especificado é consumido toda vez que a habilidade é ativada, mas excepcionalmente o material pode não ser consumido, caso a habilidade ou característica especifique

     

    

  ## **Aspectos de Seleção:**

* **Velocidade:**  
  * Você tem 3 opções pra decidir o quão rápido suas habilidades são usadas

    

| Tier de Velocidade | Velocidade | Fator de custo |
| ----- | :---: | :---: |
| **Lento** | **10s** | \-35% |
| **Normal** | **5s (Ação Principal)** | 0% |
| **Rápido** | **2s (Ação Bônus)** | \+30% |
| **Instantâneo** | **0s (Reação)** | \+60% |

    

  * Habilidades **ofensivas** não podem ser mais rápidas que habilidades normais

    	

* **Alcance:**  
  * Você pode escolher o quão longe tuas habilidades acertam baseado nas tabelas abaixo. Adicionalmente, habilidades especiais ganham 30% de alcance bônus  
  * Você pode optar, a qualquer momento, em sacrificar 50% do efeito da habilidade para ter um alcance 50% maior

    

| Alcance | Distância (M) | Fator de custo |
| ----- | :---: | :---: |
| **Toque** | **Toque** | \-15% |
| **Curta** | **5** | 0% |
| **Média** | **10** | \+15% |
| **Longa** | **20** | \+25% |
| **Longuíssima** | **30** | \+50% |

    

* **Duração:**  
  * Caso seu feitiço tenha um efeito persistente, você naturalmente já tem que ter um sacrifício material para usá-lo. Então, por padrão, feitiços são de curta duração. No entanto, na criação da habilidade, você pode escolher aumentar essa duração, recebendo uma penalidade no custo base final dela. 

| Tier de Duração | Duração (Dados) | Média de Turnos | Fator de Custo |
| ----- | :---: | :---: | :---: |
| **Instantânea** | **1** | 1 | \-15% |
| **Curta** | **1d3 turnos** | 2 | 0% |
| **Média** | **2d3 turnos** | 4 | \+25% |
| **Longa** | **2d5 turnos** | 6 | \+50% |
| **Concentração** | **Indefinida** | N/A | \+40% |

  * Caso a habilidade seja do tipo **Especial**, cada nível desses ganha 1 dado adicional

    

* **Limite de Usos:**  
  * Os usos tem modificadores de custo baseados tanto no **número de usos**, quanto pelo **tempo de recuperação**, ambos podem ser vistos nas tabelas abaixo:

    **Número de usos:**

    

| Usos | Fator de custo | Explicação |
| :---: | :---: | :---: |
| **1** | **0%** | **Número base** |
| **2 \- 5** | **10% por uso extra** | **Ex: uma skill com 3 usos custa 20% a mais**  |
| **Escalonável** | **30% fixo** | **Fórmula de usos: 1 \+ (Nível/10)** |
| **Ilimitado** | **100%** | **Infinity, pai. Se essa opção for selecionada, você não pode interferir** |

    

    **Intervalo de Recuperação:**

* **Simples:**

| Intervalo de Recuperação | Fator de Custo | Explicação |
| :---: | :---: | :---: |
| **Por Descanso Longo** | **\-20%** | **Se você deixar sua skill recuperando nesses descansos, ela fica menos versátil, mas mais barata** |
| **Por Descanso curto** | **0% (Base)** | **Valor base. Tu descansa um pouco, tira uma soneca e acorda recuperado** |
| **Por Combate** | **\+50%** | **Permite usar habilidades relevantes em combate de forma extremamente consistente** |

  

* **Especial:**


| Intervalo de Recuperação | Fator de Custo | Explicação |
| :---: | :---: | :---: |
| **Por Sessão** | **\-25%** | **Se você deixar sua skill com um número de usos por sessão, ela fica menos versátil, mas mais barata** |
| **Por Descanso Longo** | **0% (Base)** | **Valor base. Tu dorme e acorda recuperado** |
| **Por Descanso Curto** | **\+75%** | **Permite usar habilidades poderosas várias vezes ao dia. Isso muda o patamar do personagem, então o custo de energia quase dobra.** |


  

  ## **Capacidades:**