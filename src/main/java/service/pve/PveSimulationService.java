package service.pve;

import dto.pve.BuildDTO;
import dto.pve.GameState;
import java.util.List;
import java.util.Map;

public interface PveSimulationService {

    /**
     * 프리셋 빌드 기반 시뮬레이션
     * BuildDTO 안에 playStyle / expandStyle / aggression / units 포함
     */
    List<GameState> runFullSimulation(
            Map<String, Integer> myStats,
            Map<String, Integer> aiStats,
            BuildDTO myBuild,
            BuildDTO aiBuild,
            String myRace,
            String aiRace,
            String myPlayerName,
            String aiPlayerName
    );

    /** AI용 기본 빌드 자동 생성 (유저가 빌드 없을 때도 사용) */
    BuildDTO generateDefaultBuild(String race, String vsRace);
}