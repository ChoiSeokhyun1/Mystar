package dto.pve;
import lombok.Data;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
@Data
public class GameState {
    private int gameTime = 0;
    
    // ==========================================
    // [유저 상태]
    // ==========================================
    private double minerals = 50;
    private double gas = 0;
    private int workerCount = 4;
    private double combatPower = 0;
    private double defense = 1000; // 기본 방어력
    private double mineralsPerSecond = 0; // 화면 표시용
    private double gasPerSecond = 0;      // 화면 표시용
    
    // 유저 건물/생산 현황
    private Map<String, Integer> buildingCounts = new HashMap<>();
    private List<ProductionItem> productionQueue = new ArrayList<>();
    
    // 유저 저그 라바 시스템
    private int larvaCount = 0;
    private int larvaTimer = 0;
    // (★★★ 신규) 유저 빌드 스크립트 실행 상태 추적
    private Set<Integer> myExecutedCommands = new HashSet<>(); // 실행 완료된 명령 줄 번호
    private Map<Integer, Integer> myProductionTargets = new HashMap<>(); // [생산] 명령의 목표 개수
    private Map<Integer, Integer> myProductionCompleted = new HashMap<>(); // [생산] 명령의 완료 개수
    // ==========================================
    // [AI 상태]
    // ==========================================
    private double aiMinerals = 50;
    private double aiGas = 0;
    private int aiWorkerCount = 4;
    private double aiCombatPower = 0;
    private double aiDefense = 1000; // 기본 방어력
    private double aiMineralsPerSecond = 0; // 화면 표시용
    private double aiGasPerSecond = 0;      // 화면 표시용
    
    // AI 건물/생산 현황
    private Map<String, Integer> aiBuildingCounts = new HashMap<>();
    private List<ProductionItem> aiProductionQueue = new ArrayList<>();
    
    // AI 저그 라바 시스템
    private int aiLarvaCount = 0;
    private int aiLarvaTimer = 0;
    // AI 빌드 스크립트 실행 상태 추적
    private int aiBuildId = 0; // AI가 사용하는 빌드 ID
    private int aiScriptStep = 0; // (구버전 호환용)
    private Map<String, Integer> aiUnitCounts = new HashMap<>(); // (구버전 호환용)
    
    private Set<Integer> aiExecutedCommands = new HashSet<>(); // 실행 완료된 명령 줄 번호
    private Map<Integer, Integer> aiProductionTargets = new HashMap<>(); // [생산] 명령의 목표 개수
    private Map<Integer, Integer> aiProductionCompleted = new HashMap<>(); // [생산] 명령의 완료 개수
    private Integer aiAttackWaitingForCommand = null; // 공격 대기 중인 명령 인덱스
    // ==========================================
    // [공통/로그]
    // ==========================================
    private List<GameLog> newLogs = new ArrayList<>();

    // 해설에서 선수 이름으로 호명하기 위한 필드
    private String myPlayerName = "아군";
    private String aiPlayerName = "AI";
    /**
     * 초기 건물 및 라바 설정
     */
    public void setInitialBuilding(String myRace, String aiRace) {
        // 유저 초기 설정
        if ("T".equals(myRace) || "TERRAN".equals(myRace)) this.buildingCounts.put("커맨드센터", 1);
        if ("Z".equals(myRace) || "ZERG".equals(myRace)) {
            this.buildingCounts.put("해처리", 1);
            this.larvaCount = 3; 
        }
        if ("P".equals(myRace) || "PROTOSS".equals(myRace)) this.buildingCounts.put("넥서스", 1);
        // 유저 초기 일꾼 수: 8마리 고정
        this.workerCount = 8;
        if ("T".equals(myRace) || "TERRAN".equals(myRace)) this.buildingCounts.put("SCV",  8);
        if ("Z".equals(myRace) || "ZERG".equals(myRace))   this.buildingCounts.put("드론", 8);
        if ("P".equals(myRace) || "PROTOSS".equals(myRace)) this.buildingCounts.put("프로브", 8);

        // AI 초기 설정
        if ("T".equals(aiRace) || "TERRAN".equals(aiRace)) this.aiBuildingCounts.put("커맨드센터", 1);
        if ("Z".equals(aiRace) || "ZERG".equals(aiRace)) {
            this.aiBuildingCounts.put("해처리", 1);
            this.aiLarvaCount = 3; 
        }
        if ("P".equals(aiRace) || "PROTOSS".equals(aiRace)) this.aiBuildingCounts.put("넥서스", 1);
        // AI 초기 일꾼 수: 8마리 고정
        this.aiWorkerCount = 8;
        if ("T".equals(aiRace) || "TERRAN".equals(aiRace)) this.aiBuildingCounts.put("SCV",  8);
        if ("Z".equals(aiRace) || "ZERG".equals(aiRace))   this.aiBuildingCounts.put("드론", 8);
        if ("P".equals(aiRace) || "PROTOSS".equals(aiRace)) this.aiBuildingCounts.put("프로브", 8);
    }
    
    /**
     * 로그 초기화 (매 틱마다 호출됨)
     */
    public void clearLogs() {
        this.newLogs.clear();
    }
    
}