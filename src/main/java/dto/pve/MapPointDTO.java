package dto.pve;

import lombok.Data;

@Data
public class MapPointDTO {
    private int    pointId;
    private String mapId;
    private String pointName;   // 예) 스타팅1, 스타팅2, 멀티1
    private String pointType;   // STARTING / RESOURCE / RAMP / CUSTOM
    private int    pixelX;
    private int    pixelY;
}