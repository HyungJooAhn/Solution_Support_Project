package streaming

import (
	"strings"
	"time"
)

type PacketCounter struct {
	Threshold  int
	Timeperiod float64
	Pc         int
	Ac         []AttackCounter
}

type AttackCounter struct {
	Start  time.Time
	Latest time.Time
	Count  int
	Rule   Rule
}

type Rules struct {
	Rules []Rule
}

type Rule struct {
	Name   string
	Filter []string
}

type AttackInfo struct {
	Start      time.Time
	Latest     time.Time
	Count      int
	Percent    float64
	AttackType string
}

func NewPacketCnt(r Rules, t float64, n int) *PacketCounter {
	p := PacketCounter{}
	p.Timeperiod = t
	p.Threshold = n
	for _, j := range r.Rules {
		p.AddRule(j)
	}
	return &p
}

func (this *PacketCounter) AddRule(r Rule) {
	this.Ac = append(this.Ac, AttackCounter{Rule: r})
}

func (this *PacketCounter) getRuleIndex(id int) []string {
	return this.Ac[id].Rule.Filter
}

func (this *PacketCounter) getRuleName(name string) []string {
	for _, a := range this.Ac {
		if a.Rule.Name == name {
			return a.Rule.Filter
		}
	}
	return nil
}

func (this *PacketCounter) getAttackCounters() []AttackCounter {
	return this.Ac
}

func (this *PacketCounter) Inc() {
	this.Pc++
}

func (this *Rules) AddRule(id string, r ...string) {
	this.Rules = append(this.Rules, Rule{id, r})
}

func (this *PacketCounter) Attack_detection(i int) (bool, AttackInfo) {
	var ret AttackInfo
	cnt := &this.Ac[i]
	cnt.Count++
	if cnt.Start.IsZero() {
		cnt.Start = time.Now()
	} else {
		cnt.Latest = time.Now()

		if cnt.Latest.Sub(cnt.Start).Seconds() < this.Timeperiod {
			if cnt.Count > this.Threshold {

				ret.Percent = (float64(cnt.Count) / float64(this.Pc)) * 100.0
				ret.AttackType = cnt.Rule.Name
				ret.Count = cnt.Count
				ret.Start = cnt.Start
				ret.Latest = cnt.Latest

				return true, ret
			}
		} else {
			//var mutex = &sync.Mutex{}
			//mutex.Lock()
			cnt.Count = 0
			this.Pc = 0
			cnt.Start = time.Time{}
			cnt.Latest = time.Time{}
			//mutex.Unlock()
		}
	}
	return false, ret
}

func contain_strings(s string, in []string) bool {

	check := true

	for _, i := range in {
		check = check && strings.Contains(s, i)
	}

	return check
}

func (s *Stream) DdosDetector(cnt *PacketCounter) *Stream {
	return s.Map(func(packet string, a chan AttackInfo) {

		cnt.Pc++

		for i, r := range cnt.getAttackCounters() {

			if contain_strings(packet, r.Rule.Filter) {
				check, info := cnt.Attack_detection(i)
				if check {
					a <- info
				}
				break
			}
		}
	})
}
