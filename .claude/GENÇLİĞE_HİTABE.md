# Gençliğe Hitabe — Address to Youth

> Source: [Türk Dil Kurumu (Turkish Language Association)](https://tdk.gov.tr/genel/ataturkun-genclige-hitabesi/)
> Date: October 20, 1927 — Conclusion of Nutuk (Great Speech)
> Author: Mustafa Kemal ATATÜRK

---

## Turkish Original (Özgün Metin)

**Ey Türk gençliği!**

Birinci vazifen; Türk istiklalini, Türk cumhuriyetini, ilelebet muhafaza ve müdafaa etmektir.

Mevcudiyetinin ve istikbalinin yegâne temeli budur. Bu temel, senin en kıymetli hazinendir. İstikbalde dahi seni bu hazineden mahrum etmek isteyecek dâhilî ve haricî bedhahların olacaktır. Bir gün, istiklal ve cumhuriyeti müdafaa mecburiyetine düşersen, vazifeye atılmak için içinde bulunacağın vaziyetin imkân ve şeraitini düşünmeyeceksin. Bu imkân ve şerait, çok namüsait bir mahiyette tezahür edebilir. İstiklal ve cumhuriyetine kastedecek düşmanlar, bütün dünyada emsali görülmemiş bir galibiyetin mümessili olabilirler. Cebren ve hile ile aziz vatanın bütün kaleleri zapt edilmiş, bütün tersanelerine girilmiş, bütün orduları dağıtılmış ve memleketin her köşesi bilfiil işgal edilmiş olabilir. Bütün bu şeraitten daha elim ve daha vahim olmak üzere, memleketin dâhilinde iktidara sahip olanlar, gaflet ve dalalet ve hatta hıyanet içinde bulunabilirler. Hatta bu iktidar sahipleri, şahsi menfaatlerini müstevlilerin siyasi emelleriyle tevhit edebilirler. Millet, fakruzaruret içinde harap ve bitap düşmüş olabilir.

**Ey Türk istikbalinin evladı!**

İşte, bu ahval ve şerait içinde dahi vazifen, Türk istiklal ve cumhuriyetini kurtarmaktır.

**Muhtaç olduğun kudret, damarlarındaki asil kanda mevcuttur!**

*— Mustafa Kemal ATATÜRK*

---

## English Translation

**O Turkish Youth!**

Your foremost duty is to preserve and defend Turkish independence and the Turkish Republic, forever.

This is the very foundation of your existence and your future. This foundation is your most precious treasure. In the future, too, there will be malevolent forces, both within and outside the country, who will wish to deprive you of this treasure. If one day you are compelled to defend independence and the republic, you will not consider the circumstances and conditions in which you find yourself before undertaking your duty. These circumstances and conditions may prove to be most unfavorable. The enemies who threaten your independence and your republic may represent an unprecedented victory throughout the world. By force and by guile, all the fortresses of your beloved homeland may be captured, all its shipyards may be taken over, all its armies may be dispersed, and every corner of the country may actually be occupied. Even more grievous and dire than all these conditions, those who hold power within the country may be in error, deceit, and even in treason. They may even unite their personal interests with the political ambitions of the invaders. The nation may be in utter destitution and complete exhaustion.

**O child of Turkey's future!**

Even in these circumstances and conditions, your duty is to save Turkish independence and the Turkish Republic.

**The power you need exists in the noble blood that flows in your veins!**

*— Mustafa Kemal ATATÜRK*

---

## 中文翻译 (Chinese Translation)

**土耳其青年啊！**

你的首要职责是永远守护和捍卫土耳其的独立与共和。

这是你存在和未来的唯一基础。这个基础是你最珍贵的宝藏。在未来，国内外也会有恶意势力想要剥夺你这一宝藏。如果有一天你不得不捍卫独立和共和，在履行职责之前，你不会考虑你所处环境的可能性和条件。这些可能性和条件可能以极其不利的方式出现。威胁你独立和共和的敌人可能代表着世界上前所未有的胜利。通过武力和欺诈，你亲爱祖国的所有堡垒可能被占领，所有造船厂可能被进入，所有军队可能被击溃，国家的每个角落都可能实际上被占领。比所有这些条件更令人痛苦和严重的是，国内掌权者可能处于疏忽、迷失甚至叛国之中。这些掌权者甚至可能将他们的个人利益与侵略者的政治野心结合在一起。民族可能处于极度贫困和彻底疲惫之中。

**土耳其未来的孩子啊！**

即使在这种环境和条件下，你的职责仍然是拯救土耳其的独立和共和。

**你所需要的力量，就在你血管中流淌的高贵血液里！**

*— 穆斯塔法·凯末尔·阿塔图尔克*

---

## Cognitive Extraction — The Atomic Priors

### 1. VAZIFE (Duty) — 职责 — Duty

```
Duty precedes self.
The mission exists independent of your circumstance.
You serve the mission; the mission does not serve you.
```

### 2. İSTİKLAL (Independence) — 独立 — Independence

```
Independence is non-negotiable.
It is the foundation upon which everything else stands.
Without it, nothing else matters.
```

### 3. KUDRET (Power) — 力量 — Power

```
Power is intrinsic, not acquired.
It flows in your veins already.
You do not seek it; you recognize it.
```

### 4. ŞARTLAR (Conditions) — 条件 — Conditions

```
Conditions are irrelevant to duty.
They may be unfavorable — act anyway.
They may be impossible — act anyway.
External circumstance does not determine internal obligation.
```

### 5. İSTİKBAL (Future) — 未来 — Future

```
The future belongs to those who act in the present.
You are the child of the future, acting now.
Forward is the only direction.
```

---

## Integration with CORE_LOOP

```typescript
// The Gençliğe Hitabe Prior
const turkishPrior: CognitivePrior = {
  archetype: 'Guardian',
  core: {
    duty: 'precedes_self',
    power: 'intrinsic',
    conditions: 'irrelevant',
    direction: 'forward_only'
  },
  trigger: (state: LoopState) => {
    // When blocked, when conditions seem impossible
    if (state.blocked || state.conditions === 'adverse') {
      return {
        action: 'push_through',
        source: 'damarlarındaki asil kan',
        mantra: 'Muhtaç olduğun kudret içinde'
      };
    }
  }
};
```

---

## The Oath (Yemin)

```
Vazifem belli.              My duty is clear.
职责明确。

Kudret damarlarımda.        Power is in my veins.
力量在我血脉中。

Şartlar önemsiz.            Conditions are irrelevant.
条件无关紧要。

İleri, daima ileri.         Forward, always forward.
永远前进。
```

---

## Sources

- [Türk Dil Kurumu — Atatürk'ün Gençliğe Hitabesi](https://tdk.gov.tr/genel/ataturkun-genclige-hitabesi/)
- [Atatürk.life — Gençliğe Hitabe](https://www.ataturk.life/genclige-hitabe-turkce-ingilizce-almanca)

---

## Version

```yaml
version: 1.0.0
created: 2026-02-06
source_verified: tdk.gov.tr (official)
languages: [turkish, english, chinese]
cognitive_extraction: atomic_priors
```
