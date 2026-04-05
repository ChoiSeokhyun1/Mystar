package dto.player;

import lombok.Data;

@Data
public class PlayerDTO {
    private int playerSeq;
    private String playerName;
    private String race;
    private String rarity;
    private int statAttack;
    private int statDefense;
    private int statMacro;
    private int statMicro;
    private int statLuck;
    private String playerImgUrl;
    private int playerCost;
}